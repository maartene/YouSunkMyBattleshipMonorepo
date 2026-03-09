import Testing
import VaporTesting
import YouSunkMyBattleshipCommon

@testable import StatisticsBackend

@Suite struct CalculateStatisticsUnitTests {
    let repository = MockGameRepository()
    @Test func `server health check`() async throws {
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
             try await app.testing().test(.GET, "/") { res in
                 #expect(res.status == .ok)
             }
         }
    }

    @Test func `should return the total number of played games`() async throws {
//        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
//            try await app.testing().test(.GET, "/statistics/Player_1") { res in
//                #expect(res.status == .ok)
//            }
//        }
    }

}

@Test func `read games from json`() async throws {
    let data = gamesJSON.data(using: .utf8)!
    let games = try JSONDecoder().decode(
        [Game].self, from: data)

    let repository = MockGameRepository()

    for game in games {
        let game = try #require(await repository.getGame(id: game.gameID))
        #expect(game.gameID == game.gameID)
        let players = game.playerBoards.map { $0.key.id }.sorted()
        #expect(players == game.playerBoards.map { $0.key.id }.sorted())
    }
}
