//
//  GamePersistenceAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 06/02/2026.
//

import Testing
import YouSunkMyBattleshipCommon

@testable import YouSunkMyBattleshipBE

@Suite(.tags(.`E2E tests`)) struct `Feature: Game Persistence` {
    let repository = InmemoryGameRepository()
    var gameService: GameService
    var activeGameGameState: GameState?
    var gameID = ""
    let player = Player()

    init() async throws {
        gameService = GameService(repository: repository, owner: player)
    }
    
    @Test mutating func `Scenario: Player saves and resumes game`() async throws {
        try await `Given I'm in an active game against CPU`()
        try await `When I save the game as "game1"`()
        try await `And I restart and load "game1"`()
        try await `Then the board state is exactly as I left it`()
    }
}

extension `Feature: Game Persistence` {
    private mutating func `Given I'm in an active game against CPU`() async throws {
        try await createGame(player1Board: .makeFilledBoard(), in: gameService)
        gameID = await gameService.gameID
        
        let fireCommands = [Coordinate(x: 1, y: 2), Coordinate(x: 1, y: 3), Coordinate(x: 1, y: 4)].map { GameCommand.fireAt(coordinate: $0) }
        
        for fireCommand in fireCommands {
            try await gameService.receive(fireCommand.toData())
        }
        
        activeGameGameState = try await gameService.getGameState()
    }
    
    private func `When I save the game as "game1"`() async throws {
        // happens automatically
    }
    
    private mutating func `And I restart and load "game1"`() async throws {
        gameService = GameService(repository: repository, owner: player)
        
        let loadCommand = GameCommand.load(gameID: gameID)
        
        try
        await gameService.receive(loadCommand.toData())
    }
    
    private func `Then the board state is exactly as I left it`() async throws {
        let loadedGameState = try await gameService.getGameState()
        
        #expect(loadedGameState.cells == activeGameGameState?.cells)
        #expect(loadedGameState.currentPlayer == activeGameGameState?.currentPlayer)
        #expect(loadedGameState.shipsToDestroy == activeGameGameState?.shipsToDestroy)
        #expect(loadedGameState.state == activeGameGameState?.state)
    }
}
