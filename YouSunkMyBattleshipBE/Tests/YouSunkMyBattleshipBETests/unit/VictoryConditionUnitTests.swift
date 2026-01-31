//
//  VictoryConditionTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import VaporTesting
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct VictoryConditionTests {
    @Test func `when a new game is started, the player2 board is reset`() async throws {
        let repository = InmemoryGameRepository()
        let gameService = GameService(repository: repository)
        
        await repository.setBoard(.makeAnotherFilledBoard(), for: .player1)
        let (player2Board, _) = createNearlyCompletedBoard()
        await repository.setBoard(player2Board, for: .player2)
        let gameStateBeforeNewGame = try await gameService.getGameState()
        
        let placedShips = Board.makeFilledBoard().placedShips.map { $0.toDTO() }
        let command = GameCommand.createBoard(placedShips: placedShips)
        try await gameService.receive(command.toData())
        
        let gameStateAfterNewGame = try await gameService.getGameState()
        
        #expect(gameStateBeforeNewGame.cells[.player2] != gameStateAfterNewGame.cells[.player2])
    }
}
