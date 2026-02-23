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
    let gameID: String
    let player = Player()
    
    init() async {
        gameService = GameService(repository: repository, owner: player)
        self.gameID = await gameService.gameID
    }
    
    @Test func `when a game with a CPU is started, it already has two boards`() async throws {
        try await gameService.receive(GameCommand.createGameNew(withCPU: true, speed: .fast).toData())
        
        let gameState = try await gameService.getGameState()
        #expect(gameState.cells.count == 2)
    }
    
    @Test func `when the CPU wins the game, the game goes in finished state`() async throws {
        let board = createCompletedBoard()
        await repository.setGame(Game(gameID: gameID, player1Board: board, player2Board: .makeAnotherFilledBoard()))
        
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.state == .finished)
    }
    
    @Test func `when the CPU wins the game, it notifies the player`() async throws {
        let board = createCompletedBoard()
        await repository.setGame(Game(gameID: gameID,player1Board: board, player2Board: .makeAnotherFilledBoard(), player1: player))
        
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A1")).toData())
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A2")).toData())
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A3")).toData())
        
        let gameState = try await gameService.getGameState()
        
        #expect(gameState.lastMessage == "💥 DEFEAT! The CPU sank your fleet! 💥")
    }
    
}
