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
    let spy = SpyContainer()
    let gameService: GameService
    let gameID: String
    let player = Player()
    
    init() async {
        gameService = GameService(repository: repository, sessionContainer: spy, owner: player)
        self.gameID = await gameService.gameID
    }
    
    @Test func `when a game with a CPU is started, it already has two boards`() async throws {
        try await gameService.receive(GameCommand.createGame(withCPU: true, speed: .fast).toData())
        
        let gameState = try #require(await spy.sendCalls.last)
        #expect(gameState.cells.count == 2)
    }
    
    @Test func `when the CPU wins the game, the game goes in finished state`() async throws {
        let board = createCompletedBoard()
        await repository.setGame(Game(gameID: gameID, player1Board: board, player2Board: .makeAnotherFilledBoard(), player1: player, player2: Player.cpu))
        try await gameService.receive(GameCommand.load(gameID: gameID).toData())
        
        let gameState = try #require(await spy.sendCalls.last)
        
        #expect(gameState.state == .finished)
    }
    
    @Test func `when the CPU wins the game, it notifies the player`() async throws {
        let board = createCompletedBoard()
        await repository.setGame(Game(gameID: gameID,player1Board: board, player2Board: .makeAnotherFilledBoard(), player1: player, player2: Player.cpu))
        
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A1")).toData())
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A2")).toData())
        try await gameService.receive(GameCommand.fireAt(coordinate: Coordinate("A3")).toData())
        
        let gameState = try #require(await spy.sendCalls.last)
        
        #expect(gameState.lastMessage == "💥 DEFEAT! The CPU sank your fleet! 💥")
    }
    
}
