//
//  CreateGameAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Engels, Maarten MAK on 25/02/2026.
//

import Testing
import YouSunkMyBattleshipCommon

@testable import YouSunkMyBattleshipBE

@Suite(.tags(.`E2E tests`)) struct `Feature: Game creation` {
    let repository = InmemoryGameRepository()
    let spy = SpyContainer()
    let player = Player(id: "Dani")
    let gameService: GameService
    var gameID: String?
    
    init() {
        gameService = GameService(repository: repository, sessionContainer: spy, owner: player)
    }
    
    @Test mutating func `Scenario: Player creates a game`() async throws {
        try await `Given a player with player id Dani`()
        try await `When they connect to the server`()
        try await `Then a game gets created for them`()
        try await `And they receive an empty board`()
        try await `And the gameID gets communicated back to them`()
    }
}

extension `Feature: Game creation` {
    private func `Given a player with player id Dani`() async throws {
        #expect(player.id == "Dani")
    }
    
    private func `When they connect to the server`() async throws {
        let createGameCommand = GameCommand.createGame(withCPU: false, speed: .slow)
        try await gameService.receive(createGameCommand.toData())
    }
    
    private mutating func `Then a game gets created for them`() async throws {
        let game = try #require(await repository.all().first)
        gameID = game.gameID
    }
    
    private func `And they receive an empty board`() async throws {
        let gameState = try #require(await spy.sendCalls.last)
        #expect(gameState.cells[player] == Array(repeating: Array(repeating: "🌊", count: 10), count: 10))
    }
    
    private func `And the gameID gets communicated back to them`() async throws {
        let gameState = try #require(await spy.sendCalls.last)
        #expect(gameState.gameID == gameID)
    }
}
