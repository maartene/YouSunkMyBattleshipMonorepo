//
//  CPUOpponentUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct CPUOpponentUnitTests {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    
    init() async {
        gameService = GameService(repository: repository)
    }
    
    @Test func `when the CPU wins the game, the game goes in finished state`() async throws {
        let board = createCompletedBoard()
        await repository.setGame(Game(player1Board: board, player2Board: .makeAnotherFilledBoard()))
        
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.state == .finished)
    }
    
    @Test func `when the CPU wins the game, it notifies the player`() async throws {
        let board = createCompletedBoard()
        await repository.setGame(Game(player1Board: board, player2Board: .makeAnotherFilledBoard()))
        
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A1")).toData())
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A2")).toData())
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A3")).toData())
        
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.lastMessage == "💥 DEFEAT! The CPU sank your fleet! 💥")
    }
    
}
