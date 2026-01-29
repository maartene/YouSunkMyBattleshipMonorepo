//
//  DetectShipSinkingAcceptanceTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import VaporTesting
import YouSunkMyBattleshipCommon

/// As a player
/// I want the game to end when all ships are sunk
/// So that a winner is declared

@Suite(.tags(.`E2E tests`)) class `Feature: Victory Condition` {
    var lastCellToHit: Coordinate?
    
    @Test func `Scenario: Player wins the game`() async throws {
        try await withApp(configure: configure) { app in
            try await `Given only one enemy ship remains with one unhit cell`(app)
            try await `When I fire at the last ship's remaining cell`(app)
            try await `And the game ends`(app)
        }
    }
}

extension `Feature: Victory Condition` {
    func `Given only one enemy ship remains with one unhit cell`(_ app: Application) async throws {
        let (player2Board, lastCellToHit) = createNearlyCompletedBoard()
        self.lastCellToHit = lastCellToHit
        
        await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
        await app.gameRepository?.setBoard(player2Board, for: .player2)
    }
    
    func `When I fire at the last ship's remaining cell`(_ app: Application) async throws {
        let lastCellToHit = try #require(lastCellToHit)
        try await app.testing().test(.POST, "fire", beforeRequest: { req in
            try req.content.encode(lastCellToHit)
        })
    }
    
    func `And the game ends`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            let state = try res.content.decode(GameState.self)
            #expect(state.state == .finished)
        }
    }
}
