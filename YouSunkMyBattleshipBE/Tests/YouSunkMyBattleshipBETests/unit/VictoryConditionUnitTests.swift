//
//  VictoryConditionTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct VictoryConditionTests {
    @Test func `when a new game is started, the player2 board is reset`() async throws {
        let repository = InmemoryGameRepository()
        let player = Player()
        let opponent = Player()
        let gameService = GameService(repository: repository, owner: player)
        let gameID = await gameService.gameID
        
        let (player2Board, _) = createNearlyCompletedBoard()
        let game = Game(gameID: gameID, player1Board: .makeFilledBoard(), player2Board: player2Board, player1: player, player2: opponent)
        await repository.setGame(game)
        
        let gameStateBeforeNewGame = try await gameService.getGameState()
        
        let command = GameCommand.createGameNew(withCPU: true, speed: .fast)
        try await gameService.receive(command.toData())
        
        let gameStateAfterNewGame = try await gameService.getGameState()
        
        #expect(gameStateBeforeNewGame.cells[opponent] != gameStateAfterNewGame.cells[opponent])
    }
}
