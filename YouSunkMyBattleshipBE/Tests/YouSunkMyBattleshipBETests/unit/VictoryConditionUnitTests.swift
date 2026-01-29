//
//  VictoryConditionTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import VaporTesting
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct VictoryConditionTests {
    @Suite struct ViewModelTests {
        @Test func `when all ships have been hit, the game is in finished state`() async throws {
            try await withApp(configure: configure) { app in
                await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
                let (player2Board, lastCellToHit) = createNearlyCompletedBoard()
                await app.gameRepository?.setBoard(player2Board, for: .player2)
                
                try await app.testing().test(.POST, "fire", beforeRequest: { req in
                    try req.content.encode(lastCellToHit)
                })
                
                try await app.testing().test(.GET, "gameState") { res in
                    let state = try res.content.decode(GameState.self)
                    #expect(state.state == .finished)
                }
            }
        }

        @Test func `when a new game is started, the player2 board is reset`() async throws {
            try await withApp(configure: configure) { app in
                await app.gameRepository?.setBoard(.makeAnotherFilledBoard(), for: .player1)
                let (player2Board, lastCellToHit) = createNearlyCompletedBoard()
                await app.gameRepository?.setBoard(player2Board, for: .player2)
                
                try await app.testing().test(.POST, "fire", beforeRequest: { req in
                    try req.content.encode(lastCellToHit)
                })
                
                try await app.testing().test(.POST, "board", beforeRequest: { req in
                    try req.content.encode(Board.makeFilledBoard().toDTO())
                })   

                try await app.testing().test(.GET, "gameState") { res in
                    let state = try res.content.decode(GameState.self)
                    let player2Cells = try #require(state.cells[.player2])
                    #expect(player2Cells == Array(repeating: Array(repeating: "🌊", count: 10), count: 10))
                }
            }
        }
    }
}
