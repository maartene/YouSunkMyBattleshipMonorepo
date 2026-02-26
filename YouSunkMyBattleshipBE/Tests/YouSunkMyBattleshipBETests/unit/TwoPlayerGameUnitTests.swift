//
//  TwoPlayerGameUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 24/02/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon
import Foundation
import NIOCore

@Suite(.tags(.`Unit tests`)) struct TwoPlayerGameUnitTests {
    let repository = InmemoryGameRepository()
    let gameService1: GameService
    let gameService2: GameService
    let player1 = Player()
    let player2 = Player()
    var gameID: String!
    let spyContainer = SpyContainer()
    let game: Game
    
    init() async throws {
        gameService1 = GameService(repository: repository, sessionContainer: spyContainer, owner: player1)
        gameService2 = GameService(repository: repository, sessionContainer: spyContainer, owner: player2)
        
        game = Game(gameID: "2playergame", player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)
        await repository.setGame(game)
        
        try await gameService1.receive(GameCommand.load(gameID: game.gameID).toData())
        try await gameService2.receive(GameCommand.load(gameID: game.gameID).toData())
    }
    
    @Test func `in a two player game, the CPU does not take turns`() async throws {
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A1")).toData())
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A2")).toData())
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A3")).toData())
        
        let state = try #require(await spyContainer.lastSendCallFor(player1))
        #expect(state.currentPlayer == player2)
    }
    
    @Test func `in a two player game, both players are notified of important events`() async throws {
        let gameState = try #require(await spyContainer.lastSendCallFor(player2))
        #expect(gameState.lastMessage == "Game loaded successfully")
    }
    
    @Test func `in a two player game, players cannot see eachothers placed ships()`() async throws {
        let gameStateForPlayer1 = try #require(await spyContainer.lastSendCallFor(player1))
        let gameStateForPlayer2 = try #require(await spyContainer.lastSendCallFor(player2))
        #expect(gameStateForPlayer1.cells != gameStateForPlayer2.cells)
    }
    
    @Test func `in a two player game, when a ship is destroyed, players receive different messages`() async throws {
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("I6")).toData())
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("J6")).toData())
        
        let gameStateForPlayer1 = try #require(await spyContainer.lastSendCallFor(player1))
        let gameStateForPlayer2 = try #require(await spyContainer.lastSendCallFor(player2))
        #expect(gameStateForPlayer1.lastMessage == "You sank the enemy Destroyer!")
        #expect(gameStateForPlayer2.lastMessage == "Your opponent sunk your Destroyer")
    }
    
    @Test func `in a two player game, when one player wins the game, players receive different messages`() async throws {
        let game = Game(player1Board: .makeFilledBoard(), player2Board: createCompletedBoard(), player1: player1, player2: player2)
        await repository.setGame(game)
        try await gameService1.receive(GameCommand.load(gameID: game.gameID).toData())
        try await gameService2.receive(GameCommand.load(gameID: game.gameID).toData())
        
        try await gameService1.receive(GameCommand.fireAt(coordinate: Coordinate("A1")).toData())
        
        let gameStateForPlayer1 = try #require(await spyContainer.lastSendCallFor(player1))
        let gameStateForPlayer2 = try #require(await spyContainer.lastSendCallFor(player2))
        #expect(gameStateForPlayer1.lastMessage == "🎉 VICTORY! You sank the enemy fleet! 🎉")
        #expect(gameStateForPlayer2.lastMessage == "💥 DEFEAT! Your opponent sank your fleet! 💥")
    }
}
