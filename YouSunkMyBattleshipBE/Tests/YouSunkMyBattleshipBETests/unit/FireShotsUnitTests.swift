//
//  FireShotsUnitTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import VaporTesting
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct FireShotsTests {
    @Test func `the boards for both player are independent of eachother`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player2)
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                #expect(state.cells[.player1] != state.cells[.player2])
            }
        }
    }
        
    @Test func `given there is no ship at B5, when the player taps the opponents board at B5, then the cell should register as a miss`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("B5"))
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                let cells = try #require(state.cells[.player2])
                #expect(cells[1][4] == "❌")
            }
        }
    }
        
    @Test func `when the player taps their own board at B5, then that should not register as an attempt`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("B5"))
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                let cells = try #require(state.cells[.player1])
                #expect(cells[1][4] == "🌊")
            }
        }
    }
    
    @Test func `a cell that has not been tapped, should show as 🌊`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("B5"))
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                let cells = try #require(state.cells[.player2])
                #expect(cells[1][1] == "🌊")
            }
        }
    }

    @Test func `given there is a ship at C3, when the player taps the tracking board at that location, then the cell shows 💥`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("C3"))
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                let cells = try #require(state.cells[.player2])
                #expect(cells[2][2] == "💥")
            }
        }
    }
}
