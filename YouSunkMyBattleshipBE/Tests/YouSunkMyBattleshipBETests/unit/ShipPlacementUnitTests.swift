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
    let gameService: GameService
    let board = Board.makeFilledBoard()
    let player: Player
    
    init() async throws {
        let player = Player()
        self.player = player
        gameService = GameService(repository: InmemoryGameRepository(), owner: player)
        
        try await gameService.receive(
            GameCommand.createGameNew.toData()
        )
    }
    
    @Test func `when a new game is created, the board is empty`() async throws {
        let gameState = try await gameService.getGameState()
        let allCells = try #require(gameState.cells[player])
            .flatMap { $0 }
        
        #expect(allCells.count == 100)
        #expect(allCells.allSatisfy { $0 == "🌊"} )
    }
    
    @Test func `when a new game is created, it is in the placing ships state`() async throws {
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.state == .placingShips)
    }
    
    @Test func `when a new game is created, all ships need to be placed`() async throws {
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.shipsToPlace.contains("Carrier(5)"))
        #expect(gameState.shipsToPlace.contains("Battleship(4)"))
        #expect(gameState.shipsToPlace.contains("Cruiser(3)"))
        #expect(gameState.shipsToPlace.contains("Submarine(3)"))
        #expect(gameState.shipsToPlace.contains("Destroyer(2)"))
    }
    
    @Test func `when a carrier is place from A1 to A5, its cells show "🚢"`() async throws {
        let carrierCoordinates = [
            Coordinate("A1"),
            Coordinate("A2"),
            Coordinate("A3"),
            Coordinate("A4"),
            Coordinate("A5")
        ]
        
        try await gameService.receive(
            GameCommand.placeShip(ship: carrierCoordinates).toData()
        )
        
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[player])
        for coordinate in carrierCoordinates {
            #expect(cells[coordinate.y][coordinate.x] == "🚢")
        }
    }
    
    @Test func `when a carrier is place from A1 to A5, it is no longer part of the ships to place list`() async throws {
        try await placeCarrier(in: gameService)
        
        let gameState = try await gameService.getGameState()
        #expect(gameState.shipsToPlace.contains("Carrier(5)") == false)
    }
    
    @Test func `when all ships have been placed, the game goes into the play state`() async throws {
        try await placeShips(in: gameService)
        
        let gameState = try await gameService.getGameState()
        #expect(gameState.state == .play)
    }
    
    @Test func `when a player attempts to place an illegal ship, it is not placed`() async throws {
        let shipCoordinates = [
            Coordinate("A1"),
            Coordinate("B2")
        ]
        
        try await gameService.receive(
            GameCommand.placeShip(ship: shipCoordinates).toData()
        )
        
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[player])
        for coordinate in shipCoordinates {
            #expect(cells[coordinate.y][coordinate.x] == "🌊")
        }
    }
    
    @Test func `when a player attempts to place a ship where there already is one, it is not placed`() async throws {
        let shipCoordinates = [
            Coordinate("A1"),
            Coordinate("A2")
        ]
        try await gameService.receive(
            GameCommand.placeShip(ship: shipCoordinates).toData()
        )
        
        let anotherShipCoordinates = [
            Coordinate("A1"),
            Coordinate("B1"),
            Coordinate("C1"),
        ]
        try await gameService.receive(
            GameCommand.placeShip(ship: anotherShipCoordinates).toData()
        )
        
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[player])
        #expect(cells[2][0] == "🌊")
    }
    
    @Test func `when a player has already placed 5 ships, they cant place any more`() async throws {
        try await placeShips(in: gameService)
        
        let shipCoordinates = [
            Coordinate("I9"),
            Coordinate("J9")
        ]
        try await gameService.receive(
            GameCommand.placeShip(ship: shipCoordinates).toData()
        )
        
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[player])
        #expect(cells[8][8] == "🌊")
    }
    
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

        let player2Cells = try await gameService.getGameState().cells[getOpponent(from: gameService, for: player)]
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
