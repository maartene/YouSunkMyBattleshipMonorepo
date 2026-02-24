//
//  ShipPlacementAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import Foundation
import Testing
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE

@Suite struct `Feature: Ship Placement` {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    let player: Player
    
    let carrierCoordinates = [
        Coordinate("A1"),
        Coordinate("A2"),
        Coordinate("A3"),
        Coordinate("A4"),
        Coordinate("A5")
    ]
    
    init() {
        self.player = Player(id: UUID().uuidString)
        self.gameService = GameService(repository: repository, sendContainer: DummySendGameStateContainer(), owner: player)
    }
    
    @Test mutating func `Scenario: Player places a ship successfully`() async throws {
        try await `Given I have an empty board`()
        try await `When I place the Carrier at position A1 horizontally`()
        try await `Then the cells A1 through A5 display 🚢`()
        try await `And the ship placement is confirmed`()
    }

    @Test mutating func `Scenario: Player confirms being done with placing ships`() async throws {
        try await `Given I placed all my ships`()
        try await `Then it shows the game board for player 1`()
        try await `And it shows the game is in play`()
        try await `And it shows that there are 5 ships remaining to be destroyed`()
    }
}

extension `Feature: Ship Placement` {
    private func `Given I have an empty board`() async throws {
        let command = GameCommand.createGame(withCPU: false, speed: .slow)
        try await gameService.receive(command.toData())
    }
    
    private func `When I place the Carrier at position A1 horizontally`() async throws {
        try await gameService.receive(
            GameCommand.placeShip(ship: carrierCoordinates).toData()
        )
    }
    
    private func `Then the cells A1 through A5 display 🚢`() async throws {
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[player])
        for coordinate in carrierCoordinates {
            #expect(cells[coordinate.y][coordinate.x] == "🚢")
        }
    }
    
    private func `And the ship placement is confirmed`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.shipsToPlace.count == 4)
    }
    
    private mutating func `Given I placed all my ships`() async throws {
        try await createGame(player1Board: .makeFilledBoard(), in: gameService)
    }
    
    private func `Then it shows the game board for player 1`() async throws {
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
        
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.cells[player] == expectedCells)
    }
        
    private func `And it shows the game is in play`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.state == .play)
        #expect(gameState.lastMessage == "Play!")
    }
    
    private func `And it shows that there are 5 ships remaining to be destroyed`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.shipsToDestroy == 5)
    }
}
