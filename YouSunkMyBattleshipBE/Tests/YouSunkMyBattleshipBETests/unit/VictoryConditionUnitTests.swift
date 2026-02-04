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
        let gameService = GameService(repository: repository)
        
        let (player2Board, _) = createNearlyCompletedBoard()
        await repository.setGame(Game(player1Board: .makeFilledBoard(), player2Board: player2Board))
        
        let gameStateBeforeNewGame = try await gameService.getGameState()
        
        let placedShips = Board.makeFilledBoard().placedShips.map { $0.toDTO() }
        let command = GameCommand.createBoard(placedShips: placedShips, gameID: "a game")
        try await gameService.receive(command.toData())
        
        let gameStateAfterNewGame = try await gameService.getGameState()
        
        #expect(gameStateBeforeNewGame.cells[.player2] != gameStateAfterNewGame.cells[.player2])
    }
}
