//
//  TwoPlayerGameAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 24/02/2026.
//

import Foundation
import Testing
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE

@Suite(.tags(.`E2E tests`)) struct `Feature: Two Player Setup` {
    let repository = InmemoryGameRepository()
    let spy = SpyContainer()
    let gameService1: GameService
    let gameService2: GameService
    let player1 = Player()
    let player2 = Player()
    var gameID: String!
    
    init() async throws {
        gameService1 = GameService(repository: repository, sessionContainer: spy, owner: player1)
        gameService2 = GameService(repository: repository, sessionContainer: spy, owner: player2)
    }
    
    @Test mutating func `Scenario: Second player joins game`() async throws {
        try await `Given Player 1 created game "xyz789"`()
        try await `When Player 2 joins game "xyz789"`()
        try await `Then both players are connected`()
        try await `And the game is in the placing ships state`()
    }
    
    @Test mutating func `Scenario: Players place their ships`() async throws {
        try await `Given Player 1 and Player 2 are in game "xyz789"`()
        try await `When both players place their ships`()
        try await `Then the game is in the play state`()
        try await `And Player 1 is the current player`()
    }
}

@Suite(.tags(.`E2E tests`)) struct `Feature: Player vs Player gameplay` {
    let repository = InmemoryGameRepository()
    let spy = SpyContainer()
    let gameService1: GameService
    let gameService2: GameService
    let player1 = Player()
    let player2 = Player()
    var gameID: String!
    
    init() async throws {
        gameService1 = GameService(repository: repository, sessionContainer: spy, owner: player1)
        gameService2 = GameService(repository: repository, sessionContainer: spy, owner: player2)
    }
    
    @Test mutating func `Scenario: Players take turns via API`() async throws {
        try await `Given a PvP game is in progress`()
        try await `When Player 1 fires via their container`()
        try await `Then Player 2's container receives the shot`()
        try await `And Player 2 can take their turn`()
    }
}

extension `Feature: Two Player Setup` {
    private func `Given Player 1 created game "xyz789"`() async throws {
        let createGameCommand = GameCommand.createGame(withCPU: false, speed: .fast)
        try await gameService1.receive(createGameCommand.toData())
    }
    
    private mutating func `When Player 2 joins game "xyz789"`() async throws {
        let savedGames = await repository.all()
            .map { SavedGame(from: $0) }
        
        gameID = savedGames[0].gameID
        
        let joinCommand = GameCommand.join(gameID: gameID)
        try await gameService2.receive(joinCommand.toData())
    }
    
    private func `Then both players are connected`() async throws {
        let game = try #require(await repository.getGame(id: gameID))
        let players = game.playerBoards.map { $0.key }
        #expect(players.count == 2)
        #expect(players.contains(player1))
        #expect(players.contains(player2))
    }
    
    private func `And the game is in the placing ships state`() async throws {
        let game = try #require(await repository.getGame(id: gameID))
        #expect(game.state == .placingShips)
    }
    
    private func `Given Player 1 and Player 2 are in game "xyz789"`() async throws {
        let game = Game(gameID: "xyz789", player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)
        await repository.setGame(game)
        
        try await gameService1.receive(GameCommand.load(gameID: "xyz789").toData())
        try await gameService2.receive(GameCommand.load(gameID: "xyz789").toData())
    }
    
    private func `When both players place their ships`() async throws {
        let board1 = Board.makeFilledBoard()
        for ship in board1.placedShips {
            try await gameService1.receive(GameCommand.placeShip(ship: ship.coordinates).toData())
        }
        
        let board2 = Board.makeAnotherFilledBoard()
        for ship in board2.placedShips {
            try await gameService1.receive(GameCommand.placeShip(ship: ship.coordinates).toData())
        }
    }
    
    private func `Then the game is in the play state`() async throws {
        let gameState = try #require(await spy.lastSendCallFor(player1))
        #expect(gameState.state == .play)
    }
    
    private func `And Player 1 is the current player`() async throws {
        let gameState = try #require(await spy.lastSendCallFor(player2))
        #expect(gameState.currentPlayer == player1)
    }
}



extension `Feature: Player vs Player gameplay` {
    private func `Given a PvP game is in progress`() async throws {
        let game = Game(player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)
        await repository.setGame(game)
        
        try await gameService1.receive(GameCommand.load(gameID: game.gameID).toData())
        try await gameService2.receive(GameCommand.load(gameID: game.gameID).toData())
    }
    
    private func `When Player 1 fires via their container`() async throws {
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("B5")).toData())
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("H3")).toData())
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A3")).toData())
    }
    
    private func `Then Player 2's container receives the shot`() async throws {
        let gameState = try #require(await spy.lastSendCallFor(player2))
        let cells = try #require(gameState.cells[player2])
        #expect(cells[1][4] == "❌")
        #expect(cells[7][2] == "💥")
        #expect(cells[0][2] == "💥")
        #expect(cells[0][3] == "🚢")
    }
    
    private func `And Player 2 can take their turn`() async throws {
        let gameState = try #require(await spy.lastSendCallFor(player2))
        #expect(gameState.currentPlayer == player2)
    }
}
