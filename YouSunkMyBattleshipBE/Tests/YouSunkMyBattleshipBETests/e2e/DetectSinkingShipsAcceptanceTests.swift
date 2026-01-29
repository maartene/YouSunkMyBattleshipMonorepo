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
/// I want to know when I've sunk an enemy ship
/// So that I can track my progress
@Suite(.tags(.`E2E tests`)) struct `Feature: Ship Sinking Detection` {
    @Test func `Scenario: Player sinks enemy destroyer`() async throws {
        try await withApp(configure: configure) { app in
            try await `Given the enemy has a Destroyer at I9-J9`(app)
            try await `And I have hit I9`(app)
            try await `When I fire at J9`(app)
            try await `Then both I9 and J9 show 🔥`(app)
            try await `And I see one less remaining ship to destroy`(app)
        }
    }
}

extension `Feature: Ship Sinking Detection` {
    func `Given the enemy has a Destroyer at I9-J9`(_ app: Application) async throws {
        await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
        await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player2)
    }
    
    func `And I have hit I9`(_ app: Application) async throws {
        try await app.testing().test(.POST, "fire", beforeRequest: { req in
            try req.content.encode(Coordinate("I9"))
        })
    }
    
    func `When I fire at J9`(_ app: Application) async throws {
        try await app.testing().test(.POST, "fire", beforeRequest: { req in
            try req.content.encode(Coordinate("J9"))
        })
    }
    
    func `Then both I9 and J9 show 🔥`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            let state = try res.content.decode(GameState.self)
            let cells = try #require(state.cells[.player2])
            #expect(cells[8][8] == "🔥")
            #expect(cells[9][8] == "🔥")
        }
    }
        
    func `And I see one less remaining ship to destroy`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            let state = try res.content.decode(GameState.self)
            #expect(state.shipsToDestroy == 4)
        }
    }
}
