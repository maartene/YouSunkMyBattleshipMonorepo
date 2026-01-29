//
//  ShipPlacementUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import Testing
import VaporTesting
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE

@Suite struct `Ship Placement tests` {
    @Test func `when a valid board is submitted, it returns a created message`() async throws {
        let board = Board.makeFilledBoard()
        
        try await withApp(configure: configure) { app in
            let boardDTO = board.toDTO()
            
            try await app.testing().test(.POST, "board", beforeRequest: { req in
                try req.content.encode(boardDTO)
            }, afterResponse: { res in
                #expect(res.status == .created)
            })
        }
    }
    
    @Test func `given a valid board has been submitted, calling gameState returns it`() async throws {
        let board = Board.makeFilledBoard()
        
        try await withApp(configure: configure) { app in
            let boardDTO = board.toDTO()
            
            try await app.testing().test(.POST, "board", beforeRequest: { req in
                try req.content.encode(boardDTO)
            })
            
            try await app.testing().test(.GET, "gameState") { res in
                let state = try res.content.decode(GameState.self)
                let player1Cells = try #require(state.cells[.player1])
                
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
                #expect(player1Cells == expectedCells)
            }
        }
    }
    
    @Test func `when a board with too little ships is submitted, an error is returned`() async throws {
        let boardDTO = Board.makeFilledBoard().toDTO()
        var placedShips = boardDTO.placedShips
        placedShips.removeFirst()
        let notEnoughShipsBoard = BoardDTO(placedShips: placedShips)
        
        try await withApp(configure: configure) { app in
            try await app.testing().test(.POST, "board", beforeRequest: { req in
                try req.content.encode(notEnoughShipsBoard)
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
            })
        }
    }
    
    @Test func `when a board with overlapping ships is submitted, an error is returned`() async throws {
        let boardDTO = Board.makeFilledBoard().toDTO()
        var placedShips = boardDTO.placedShips
        placedShips[0] = PlacedShipDTO(name: "Carrier", coordinates: [
            Coordinate(x: 2, y: 2),
            Coordinate(x: 2, y: 3),
            Coordinate(x: 2, y: 4),
            Coordinate(x: 2, y: 5),
            Coordinate(x: 2, y: 6)
        ])
        let overlappingShipBoard = BoardDTO(placedShips: placedShips)
        
        try await withApp(configure: configure) { app in
            try await app.testing().test(.POST, "board", beforeRequest: { req in
                try req.content.encode(overlappingShipBoard)
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
            })
        }
    }
}
