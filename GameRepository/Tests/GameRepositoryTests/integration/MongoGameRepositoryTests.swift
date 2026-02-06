//
//  MongoGameRepositoryTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 06/02/2026.
//

import Testing
import YouSunkMyBattleshipCommon

@testable import GameRepository

@Suite struct MongoGameRepositoryTests {
    let repository: MongoGameRepository

    init() async throws {
        repository = try await MongoGameRepository()
    }

    @Test func `should throw an error when it cant connect to the databse`() async {
        await #expect(throws: (any Error).self) {
            _ = try await MongoGameRepository(connectionString: "mongodb://wrong/db")
        }
    }

    @Test func `should be able to save a game and retrieve it`() async throws {
        let game = Game(player1Board: .makeAnotherFilledBoard(), player2Board: .makeFilledBoard())
        await repository.setGame(game)

        let retrievedGame = try #require(await repository.getGame(id: game.gameID))

        #expect(retrievedGame == game)
    }

    @Test func `should be able to get a list of games`() async throws {
        let games = (0..<10)
            .map { i in
                Game(
                    gameID: "game\(i)", player1Board: .makeAnotherFilledBoard(),
                    player2Board: .makeFilledBoard())
            }

        for game in games {
            await repository.setGame(game)
        }

        let retrievedGames = await repository.all()

        for game in games {
            #expect(retrievedGames.contains(game))
        }
    }
}

extension Game: @retroactive Equatable {
    public static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.player1Board == rhs.player1Board && lhs.player2Board == rhs.player2Board
            && lhs.currentPlayer == rhs.currentPlayer
    }

}

extension Board: @retroactive Equatable {
    public static func == (lhs: Board, rhs: Board) -> Bool {
        lhs.cells == rhs.cells
    }
}
