//
//  FireShotsUnitTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct FireShotsTests {
    let repository = InmemoryGameRepository()
    let spy = SpyContainer()
    let gameService: GameService
    let gameID: String
    let player: Player
    let opponent: Player
    
    init() async throws {
        let player = Player()
        self.player = player
        gameService = GameService(repository: repository, sessionContainer: spy, owner: player)
        try await createGame(player1Board: .makeFilledBoard(), in: gameService)
        gameID = await gameService.gameID
        let gameState = try #require(await spy.sendCalls.last)
        let opponent = try #require(gameState.cells.keys.first { $0 != player })
        self.opponent = opponent
    }
    
    @Test func `the boards for both player are independent of eachother`() async throws {
        let gameState = try #require(await spy.sendCalls.last)
        
        #expect(gameState.cells[player] != gameState.cells[opponent])
    }
        
    @Test func `given there is no ship at B5, when the player taps the opponents board at B5, then the cell should register as a miss`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("B5"))
        
        try await gameService.receive(command.toData())
            
        let gameState = try #require(await spy.sendCalls.last)
        let cells = try #require(gameState.cells[opponent])
        #expect(cells[1][4] == "❌")
    }
    
    @Test func `a cell that has not been tapped, should show as 🌊`() async throws {
        let command = GameCommand.fireAt(coordinate: Coordinate("B5"))
        
        try await gameService.receive(command.toData())
            
        let gameState = try #require(await spy.sendCalls.last)
        let cells = try #require(gameState.cells[opponent])
        #expect(cells[1][1] == "🌊")
    }
}
