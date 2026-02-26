//
//  DetectShipSinkingAcceptanceTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 28/01/2026.
//

import Testing
import YouSunkMyBattleshipCommon

@testable import YouSunkMyBattleshipBE

/// As a player
/// I want to know when I've sunk an enemy ship
/// So that I can track my progress
@Suite(.tags(.`E2E tests`)) struct `Feature: Ship Sinking Detection` {
    let repository = InmemoryGameRepository()
    let spy = SpyContainer()
    let gameService: GameService
    let gameID: String
    let player: Player
    
    init() async throws {
        let player = Player()
        self.player = player
        self.gameService = GameService(repository: repository, sessionContainer: spy, owner: player)
        gameID = await gameService.gameID
    }
    
    @Test func `Scenario: Player sinks enemy destroyer`() async throws {
        try await `Given the enemy has a Destroyer at I9-J9`()
        try await `And I have hit I9`()
        try await `When I fire at J9`()
        try await `Then both I9 and J9 show 🔥`()
        try await `And I see "You sank the enemy Destroyer!"`()
        try await `And I see one less remaining ship to destroy`()
    }
}

extension `Feature: Ship Sinking Detection` {
    func `Given the enemy has a Destroyer at I9-J9`() async throws {
        await repository.setGame(Game(gameID: gameID, player1Board: .makeAnotherFilledBoard(), player2Board: .makeFilledBoard(), player1: player))
    }

    func `And I have hit I9`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("I9"))
        try await gameService.receive(command.toData())
    }

    func `When I fire at J9`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("J9"))
        try await gameService.receive(command.toData())
    }

    func `Then both I9 and J9 show 🔥`() async throws {
        let gameState = try #require(await spy.sendCalls.last)
        let opponent = try #require(gameState.opponentFor(player))
        let cells = try #require(gameState.cells[opponent])
        #expect(cells[8][8] == "🔥")
        #expect(cells[9][8] == "🔥")
    }

    func `And I see "You sank the enemy Destroyer!"`() async throws {
        let gameState = try #require(await spy.lastSendCallFor(player))
        #expect(gameState.lastMessage == "You sank the enemy Destroyer!")
    }

    func `And I see one less remaining ship to destroy`() async throws {
        let gameState = try #require(await spy.lastSendCallFor(player))
        #expect(gameState.shipsToDestroy == 4)
    }
}
