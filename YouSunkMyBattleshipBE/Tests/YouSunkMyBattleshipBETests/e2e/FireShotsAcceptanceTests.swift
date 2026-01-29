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
    @Test func `Scenario: Player fires and misses`() async throws {
        try await withApp(configure: configure) { app in
            await `Given the game has started with all ships placed`(app)
            try await `When I fire at coordinate B5`(app)
            try await `Then the tracking board shows ❌ at B5`(app)
        }
    }
        
    @Test func `Scenario: Player fires and hits`() async throws {
        try await withApp(configure: configure) { app in
            await `Given the game has started with all ships placed`(app)
            `And one of the ship has a piece place on B2`()
            try await `When I fire at coordinate B2`(app)
            try await `Then the tracking board shows 💥 at B2`(app)
        }
    }
}

extension `Feature: Firing Shots` {
    private func `Given the game has started with all ships placed`(_ app: Application) async {
        await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
        await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player2)
    }
    
    private func `When I fire at coordinate B5`(_ app: Application) async throws {
        try await app.testing().test(.POST, "fire", beforeRequest: { req in
            try req.content.encode(Coordinate("B5"))
        })
    }
    
    private func `Then the tracking board shows ❌ at B5`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            let gameState = try res.content.decode(GameState.self)
            #expect(gameState.cells[.player2]![1][4] == "❌")
        }
    }
    
    private func `And one of the ship has a piece place on B2`() {
        
    }
    
    private func `When I fire at coordinate B2`(_ app: Application) async throws {
        try await app.testing().test(.POST, "fire", beforeRequest: { req in
            try req.content.encode(Coordinate("B2"))
        })
    }
    
    private func `Then the tracking board shows 💥 at B2`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            let gameState = try res.content.decode(GameState.self)
            #expect(gameState.cells[.player2]![1][1] == "💥")
        }
    }
}
