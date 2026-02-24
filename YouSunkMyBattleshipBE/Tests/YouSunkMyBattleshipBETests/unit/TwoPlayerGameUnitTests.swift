//
//  TwoPlayerGameUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 24/02/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct TwoPlayerGameUnitTests {
    let repository = InmemoryGameRepository()
    let gameService1: GameService
    let gameService2: GameService
    let player1 = Player()
    let player2 = Player()
    var gameID: String!
    
    init() async throws {
        gameService1 = GameService(repository: repository, owner: player1)
        gameService2 = GameService(repository: repository, owner: player2)
    }
    
    @Test func `in a two player game, the CPU does not take turns`() async throws {
        let game = Game(gameID: "2playergame", player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)
        await repository.setGame(game)
        
        try await gameService1.receive(GameCommand.load(gameID: game.gameID).toData())
        try await gameService2.receive(GameCommand.load(gameID: game.gameID).toData())
        
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A1")).toData())
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A2")).toData())
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A3")).toData())
        
        let state = try await gameService2.getGameState()
        #expect(state.currentPlayer == player2)
    }
    
    @Test func `in a two player game, both players are notified of important events`() async throws {
        notImplemented()
    }
}
