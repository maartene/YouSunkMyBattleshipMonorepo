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
    let gameService1: GameService
    let gameService2: GameService
    let player1 = Player()
    let player2 = Player()
    var gameID: String!
    
    init() async throws {
        gameService1 = GameService(repository: repository, sessionContainer: DummySendGameStateContainer(), owner: player1)
        gameService2 = GameService(repository: repository, sessionContainer: DummySendGameStateContainer(), owner: player2)
    }
    
    @Test mutating func `Scenario: Second player joins game`() async throws {
        try await `Given Player 1 created game "xyz789"`()
        try await `When Player 2 joins game "xyz789"`()
        try await `Then both players are connected`()
        try await `And the game is in the placing ships state`()
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
}
