//
//  FireShotsAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Testing
import VaporTesting
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE

@Suite struct `Feature: Firing Shots` {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    
    init() async {
        gameService = GameService(repository: repository)
    }
    
    @Test func `Scenario: Player fires and misses`() async throws {
        await `Given the game has started with all ships placed`()
        try await `When I fire at coordinate B5`()
        try await `Then the tracking board shows ❌ at B5`()
        try await `And I receive feedback "Miss!"`()
    }
        
    @Test func `Scenario: Player fires and hits`() async throws {
        await `Given the game has started with all ships placed`()
        await `And one of the ship has a piece place on H3`()
        try await `When I fire at coordinate H3`()
        try await `Then the tracking board shows 💥 at H3`()
        try await `And I receive feedback "Hit!"`()
    }
}

extension `Feature: Firing Shots` {
    private func `Given the game has started with all ships placed`() async {
        await repository.setBoard(.makeFilledBoard(), for: .player1)
        await repository.setBoard(.makeAnotherFilledBoard(), for: .player2)
    }
    
    private func `When I fire at coordinate B5`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("B5"))
        try await gameService.receive(command.toData())
    }
    
    private func `Then the tracking board shows ❌ at B5`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.cells[.player2]![1][4] == "❌")
    }
    
    private func `And I receive feedback "Miss!"`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.lastMessage == "Miss!")
    }
    
    private func `And one of the ship has a piece place on H3`() async {
        let board = await repository.getBoard(for: .player2)!
        #expect(board.placedShips.contains(where: { ship in
            ship.coordinates.contains(Coordinate("H3"))
        }))
    }
    
    private func `When I fire at coordinate H3`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("H3"))
        try await gameService.receive(command.toData())
    }
    
    private func `Then the tracking board shows 💥 at H3`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.cells[.player2]![7][2] == "💥")
    }
    
    private func `And I receive feedback "Hit!"`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.lastMessage == "Hit!")
    }
}
