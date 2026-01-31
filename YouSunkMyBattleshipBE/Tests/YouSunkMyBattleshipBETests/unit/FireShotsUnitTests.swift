//
//  FireShotsUnitTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct FireShotsTests {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    
    init() async {
        gameService = GameService(repository: repository)
        await repository.setBoard(.makeFilledBoard(), for: .player1)
        await repository.setBoard(.makeAnotherFilledBoard(), for: .player2)
    }
    
    @Test func `the boards for both player are independent of eachother`() async throws {
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.cells[.player1] != gameState.cells[.player2])
    }
        
    @Test func `given there is no ship at B5, when the player taps the opponents board at B5, then the cell should register as a miss`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("B5"))
        
        try await gameService.receive(command.toData())
            
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[.player2])
        #expect(cells[1][4] == "❌")
    }
    
    @Test func `a cell that has not been tapped, should show as 🌊`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("B5"))
        
        try await gameService.receive(command.toData())
            
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[.player2])
        #expect(cells[1][1] == "🌊")
    }
}
