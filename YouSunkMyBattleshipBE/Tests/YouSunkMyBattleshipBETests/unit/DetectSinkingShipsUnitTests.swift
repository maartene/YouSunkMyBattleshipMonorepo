//
//  DetectShipSinkingShipsUnitTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 28/02/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import VaporTesting
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct DetectShipSinkingTests {
    @Test func `when all coordinates from a ship have been hit, the number of ships to destroy goes down by one`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("I9"))
            })
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("J9"))
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                #expect(state.shipsToDestroy == 4)
            }
        }
    }
    
    @Test func `when all coordinates from a ship have been hit, it is shown as 🔥`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("I9"))
            })
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("J9"))
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                let cells = try #require(state.cells[.player2])
                #expect(cells[8][8] == "🔥")
                #expect(cells[9][8] == "🔥")
            }
        }
    }
    
    @Test func `when all coordinates from a ship have been hit again, the number of ships to destroy does not go down further`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("I9"))
            })
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("J9"))
            })
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("I9"))
            })
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("J9"))
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                #expect(state.shipsToDestroy == 4)
            }
        }
    }
    
    @Test func `given all coordinates from a ship have been hit, we can retrieve its name`() async throws {
        try await withApp(configure: configure) { app in
            await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
            await app.gameRepository?.setBoard(.makeFilledBoard(), for: .player2)
            
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("I9"))
            })
            try await app.testing().test(.POST, "fire", beforeRequest: { req in
                try req.content.encode(Coordinate("J9"))
            })
            
            try await app.testing().test(.GET, "shipAt", beforeRequest: { req in
                try req.content.encode(Coordinate("I9"))
            }, afterResponse: { res in
                let shipName = try res.content.decode(String.self)
                #expect(shipName == "Destroyer")
            })
        }
    }
}
