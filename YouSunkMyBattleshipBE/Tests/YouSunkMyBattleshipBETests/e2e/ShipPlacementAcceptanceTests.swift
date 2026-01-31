//
//  ShipPlacementAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import Testing
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE

@Suite struct `Feature: Ship Placement` {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    var placedShips: [Board.PlacedShip] = []
    
    init() {
        self.gameService = GameService(repository: repository)
    }
    
    @Test mutating func `Scenario: Player confirms being done with placing ships`() async throws {
        `Given I placed all my ships`()
        try await `When I confirm placement`()
        try await `Then it shows the game board for player 1`()
        try await `And it shows the game is in play`()
        try await `And it shows that there are 5 ships remaining to be destroyed`()
    }
}

extension `Feature: Ship Placement` {
    private mutating func `Given I placed all my ships`() {
        let board = Board.makeFilledBoard()
        placedShips = board.placedShips
    }
    
    private mutating func `When I confirm placement`() async throws {
        let placedShipsDTO = placedShips.map { $0.toDTO() }
        let command = GameCommand.createBoard(placedShips: placedShipsDTO)
        try await gameService.receive(command.toData())
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
        
        #expect(gameState.cells[.player1] == expectedCells)
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
