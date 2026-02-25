//
//  CPUOpponentAcceptanceTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//


import Testing
import YouSunkMyBattleshipCommon

@testable import YouSunkMyBattleshipBE

@Suite(.tags(.`E2E tests`)) struct `Feature: CPU Opponent` {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    let gameID: String
    let player = Player()
    
    init() async throws {
        self.gameService = GameService(repository: repository, sessionContainer: DummySendGameStateContainer(), owner: player, bot: FixedBot(fixedMoves: [Coordinate("B2"), Coordinate("C2"), Coordinate("A1")]))
        try await createGame(player1Board: .makeFilledBoard(), in: gameService)
        gameID = await gameService.gameID
    }
    
    @Test func `Scenario: CPU takes its turn`() async throws {
        try await `Given it's the CPU's turn`()
        try await `When the CPU fires`()
        try await `Then I see "CPU fires at [coordinate]"`()
        try await `And my board updates with hit 💥 or miss ❌`()
    }
}

extension `Feature: CPU Opponent` {
    private func `Given it's the CPU's turn`() async throws {
        let commands = [
            "A1", "A2", "A3"
        ]
            .map { Coordinate($0) }
            .map { GameCommand.fireAt(coordinate: $0) }
        
        for command in commands {
            try await gameService.receive(command.toData())
        }
    }
    
    private func `When the CPU fires`() async throws {
        // no action needed, the CPU fires automatically after the player fires
    }
    
    private func `Then I see "CPU fires at [coordinate]"`() async throws {
        let gameState = try await gameService.getGameState()
        #expect(gameState.lastMessage == "CPU fires at B2, C2 and A1")
    }
    
    private func `And my board updates with hit 💥 or miss ❌`() async throws {
        let gameState = try await gameService.getGameState()
        let cells = try #require(gameState.cells[player])
        #expect(cells[1][1] == "💥")
        #expect(cells[2][1] == "💥")
        #expect(cells[0][0] == "❌")
    }
}
