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
    let player1 = Player()
    let game1: Game
    let game2: Game
    
    init() async {
        game1 = Game(player: player1, cpu: false)
        game2 = Game(player: player1, cpu: true)
        await repository.setGame(game1)
        await repository.setGame(game2)
    }
    
    @Test func `two games are seperate`() async throws {
        let gameService1 = GameService(repository: repository, sendContainer: DummySendGameStateContainer())
        let gameService2 = GameService(repository: repository, sendContainer: DummySendGameStateContainer())
        
        try await createGame(player1Board: .makeFilledBoard(), in: gameService1)
        try await createGame(player1Board: .makeAnotherFilledBoard(), in: gameService2)
        
        let gameState1 = try await gameService1.getGameState()
        let gameState2 = try await gameService2.getGameState()
        
        #expect(gameState1.cells != gameState2.cells)
    }
    
    @Test func `can get a list of in progress games`() async throws {
        let expectedSavedGames = [game1, game2].map { SavedGame(from: $0) }
        
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
            try await app.testing().test(.GET, "games") { res in
                let savedGames = try JSONDecoder().decode([SavedGame].self, from: res.body)
                #expect(res.status == .ok)
                #expect(savedGames.count == 2)
                for expectedSavedGame in expectedSavedGames {
                    #expect(savedGames.contains(expectedSavedGame))
                }
            }
        }
    }
    
    @Test func `a game with only one player can be joined`() async throws {
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
            try await app.testing().test(.GET, "games") { res in
                let savedGames = try JSONDecoder().decode([SavedGame].self, from: res.body)
                #expect(res.status == .ok)
                let joinableGame = try #require(savedGames.first { $0.canJoin })
                #expect(joinableGame == SavedGame(from: game1))
            }
        }
    }
}
