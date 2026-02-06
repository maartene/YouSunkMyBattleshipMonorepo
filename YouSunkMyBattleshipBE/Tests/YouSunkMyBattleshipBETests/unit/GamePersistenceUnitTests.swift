//
//  GamePersistenceUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 06/02/2026.
//

import Testing
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE
import VaporTesting

@Suite(.tags(.`Unit tests`)) struct GamePersistenceUnitTests {
    let repository = InmemoryGameRepository()
    
    @Test func `two games are seperate`() async throws {
        let gameService1 = GameService(repository: repository)
        let gameService2 = GameService(repository: repository)
        
        try await createGame(player1Board: .makeFilledBoard(), in: gameService1)
        try await createGame(player1Board: .makeAnotherFilledBoard(), in: gameService2)
        
        let gameState1 = try await gameService1.getGameState()
        let gameState2 = try await gameService2.getGameState()
        
        #expect(gameState1.cells != gameState2.cells)
    }
    
    @Test func `can get a list of in progress games`() async throws {
        let repository = InmemoryGameRepository()
        await repository.setGame(Game(gameID: "game1", player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard()))
        await repository.setGame(Game(gameID: "game2", player1Board: .makeAnotherFilledBoard(), player2Board: .makeFilledBoard()))
        
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
            try await app.testing().test(.GET, "games") { res in
                let gameIDs = try JSONDecoder().decode([String].self, from: res.body)
                #expect(res.status == .ok)
                #expect(gameIDs == ["game1", "game2"])
            }
        }
    }
}
