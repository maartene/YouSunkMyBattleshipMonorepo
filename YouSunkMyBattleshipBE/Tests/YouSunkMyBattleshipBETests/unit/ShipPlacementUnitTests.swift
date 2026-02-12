//
//  ShipPlacementUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import Testing
import YouSunkMyBattleshipCommon
import Foundation

@testable import YouSunkMyBattleshipBE

@Suite struct `Ship Placement tests` {
    let gameService = GameService(repository: InmemoryGameRepository())
    let board = Board.makeFilledBoard()
    
    @Test func `when a valid board is submitted, gamestate is returned`() async throws {
        let placedShips = board.placedShips.map { $0.toDTO() }
        
        try await gameService.receive(
            GameCommand.createGame(placedShips: placedShips, speed: .slow).toData()
        )

        #expect(try await gameService.getGameState().state == .play)
    }

    @Test
    func
        `given a valid board has been submitted, calling gameState returns a target board with only water and ships`()
        async throws
    {
        let placedShips = board.placedShips.map { $0.toDTO() }
        
        try await gameService.receive(
            GameCommand.createGame(placedShips: placedShips, speed: .fast).toData()
        )
        let expectedCells = [
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
        ]

        let player2Cells = try await gameService.getGameState().cells[.player2]
        #expect(player2Cells == expectedCells)
    }

    @Test func `when a board with too little ships is submitted, an error is returned`()
        async throws
    {
        var placedShips = Board.makeAnotherFilledBoard().placedShips
        placedShips.removeFirst()
        let notEnoughPlacedShips = placedShips.map { $0.toDTO() }

        await #expect(throws: (any Error).self) {
            try await gameService.receive(
                GameCommand.createGame(placedShips: notEnoughPlacedShips, speed: .fast).toData()
            )
        }
    }

    @Test func `when a board with overlapping ships is submitted, an error is returned`()
        async throws
    {
        var placedShips = board.placedShips.map { $0.toDTO() }
        placedShips[0] = PlacedShipDTO(
            name: "Carrier",
            coordinates: [
                Coordinate(x: 2, y: 2),
                Coordinate(x: 2, y: 3),
                Coordinate(x: 2, y: 4),
                Coordinate(x: 2, y: 5),
                Coordinate(x: 2, y: 6),
            ])
        
        await #expect(throws: (any Error).self) {
            try await gameService.receive(
                GameCommand.createGame(placedShips: placedShips, speed: .fast).toData()
            )
        }
    }
}

extension GameCommand {
    func toData() -> Data {
        guard let data = try? JSONEncoder().encode(self) else {
            fatalError("Failed to encode GameCommand \(self) to Data")
        }
        return data
    }
}
