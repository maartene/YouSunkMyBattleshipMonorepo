//
//  ShipPlacementAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import Testing
import VaporTesting
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE

@Suite struct `Feature: Ship Placement` {
    var board: Board?
    
    @Test mutating func `Scenario: Player confirms being done with placing ships`() async throws {
        try await withApp(configure: configure) { app in
            try await `Given I placed all my ships`(app)
            try await `When I confirm placement`(app)
            try await `Then it shows the game board for player 1`(app)
            try await `And it shows the game board for player 2 with only 🌊`(app)
            try await `And it shows the game is in play`(app)
            try await `And it shows that there are 5 ships remaining to be destroyed`(app)
        }
    }
}

extension `Feature: Ship Placement` {
    private mutating func `Given I placed all my ships`(_ app: Application) async throws {
        board = Board.makeFilledBoard()
    }
    
    private mutating func `When I confirm placement`(_ app: Application) async throws {
        let board = try #require(board)
        let boardDTO = board.toDTO()
        
        try await app.testing().test(.POST, "board", beforeRequest: { req in
            try req.content.encode(boardDTO)
        })
    }
    
    private func `Then it shows the game board for player 1`(_ app: Application) async throws {
        let expectedCells = [
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🚢", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🚢", "🚢", "🚢", "🚢", "🚢", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🚢", "🚢", "🚢", "🚢", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🚢", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🚢", "🌊", "🌊", "🌊", "🚢", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊"]
        ]
        
        try await app.testing().test(.GET, "gameState") { res in
            let state = try res.content.decode(GameState.self)
            #expect(state.cells[.player1] == expectedCells)
        }
    }
    
    private func `And it shows the game board for player 2 with only 🌊`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            let state = try res.content.decode(GameState.self)
            state.cells[.player2, default: []].flatMap { $0 }.forEach {
                #expect($0 == "🌊")
            }
        }
    }
    
    private func `And it shows the game is in play`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            #expect(res.status == .ok)
            let state = try res.content.decode(GameState.self)
            #expect(state.state == .play)
        }
    }
    
    private func `And it shows that there are 5 ships remaining to be destroyed`(_ app: Application) async throws {
        try await app.testing().test(.GET, "gameState") { res in
            #expect(res.status == .ok)
            let state = try res.content.decode(GameState.self)
            #expect(state.shipsToDestroy == 5)
        }
    }
}
