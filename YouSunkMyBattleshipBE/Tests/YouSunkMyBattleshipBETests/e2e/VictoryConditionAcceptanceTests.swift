//
//  DetectShipSinkingAcceptanceTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

/// As a player
/// I want the game to end when all ships are sunk
/// So that a winner is declared

@Suite(.tags(.`E2E tests`)) class `Feature: Victory Condition` {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    let gameID: String
    let player = Player()
    
    init() async {
        gameService = GameService(repository: repository, sendContainer: DummySendGameStateContainer(), owner: player)
        gameID = await gameService.gameID
    }
    
    var lastCellToHit: Coordinate?
    
    @Test func `Scenario: Player wins the game`() async throws {
        try await `Given only one enemy ship remains with one unhit cell`()
        try await `When I fire at the last ship's remaining cell`()
        try await `Then I see "🎉 VICTORY! You sank the enemy fleet! 🎉"`()
        try await `And the game ends`()
    }
}

extension `Feature: Victory Condition` {
    func `Given only one enemy ship remains with one unhit cell`() async throws {
        let (player2Board, lastCellToHit) = createNearlyCompletedBoard()
        self.lastCellToHit = lastCellToHit
        
        await repository.setGame(Game(gameID: gameID, player1Board: .makeAnotherFilledBoard(), player2Board: player2Board, player1: player))
    }
    
    func `When I fire at the last ship's remaining cell`() async throws {
        let lastCellToHit = try #require(lastCellToHit)
        let command = GameCommand.fireAt(coordinate: lastCellToHit)
        try await gameService.receive(command.toData())
    }
    
    func `Then I see "🎉 VICTORY! You sank the enemy fleet! 🎉"`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.lastMessage == "🎉 VICTORY! You sank the enemy fleet! 🎉")
    }
    
    func `And the game ends`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.state == .finished)
    }
}
