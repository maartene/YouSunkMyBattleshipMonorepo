import Foundation
import GameRepository
import YouSunkMyBattleshipCommon
import Testing

final class MockGameRepository: GameRepository {
    let games: [String: Game]

    init() {
        let data = gamesJSON.data(using: .utf8)!
        let games = try! JSONDecoder().decode(
            [Game].self, from: data)
        self.games = Dictionary(uniqueKeysWithValues: games.map { ($0.gameID, $0) })
    }

    func setGame(_ game: Game) async {

    }

    func getGame(id: String) async -> Game? {
        return games[id]
    }

    func all() async -> [Game] {
        return Array(games.values)
    }
}

func notImplemented() {
    Issue.record("Not implemented")
}

extension Tag {
    @Tag static var `E2E tests`: Self
    @Tag static var `Unit tests`: Self
    @Tag static var `Integration tests`: Self
}
