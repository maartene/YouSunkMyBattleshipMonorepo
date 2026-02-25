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
        let spy = SpyContainer()
        let player = Player()
        let opponent = Player()
        let gameService = GameService(repository: repository, sessionContainer: spy, owner: player)
        let gameID = await gameService.gameID
        
        let (player2Board, _) = createNearlyCompletedBoard()
        let game = Game(gameID: gameID, player1Board: .makeFilledBoard(), player2Board: player2Board, player1: player, player2: opponent)
        await repository.setGame(game)
        try await gameService.receive(GameCommand.load(gameID: gameID).toData())
        
        let gameStateBeforeNewGame = try #require(await spy.lastSendCallFor(player))
        
        let command = GameCommand.createGame(withCPU: true, speed: .fast)
        try await gameService.receive(command.toData())
        
        let gameStateAfterNewGame = try #require(await spy.lastSendCallFor(player))
        
        #expect(gameStateBeforeNewGame.cells[opponent] != gameStateAfterNewGame.cells[opponent])
    }
}
