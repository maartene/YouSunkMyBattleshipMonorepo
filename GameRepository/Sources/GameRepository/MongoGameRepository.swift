//
//  MongoGameRepository.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 06/02/2026.
//

import MongoKitten
import YouSunkMyBattleshipCommon

public actor MongoGameRepository: GameRepository {
    private let db: MongoDatabase
    private let encoder = BSONEncoder()
    private let decoder = BSONDecoder()
    private let games: MongoCollection

    public init(connectionString: String = "mongodb://localhost:27017/game_database") async throws {
        var db: MongoDatabase?
        var attempts = 0

        while db == nil && attempts < 5 {
            print("Attempt \(attempts) to connect to database: \(connectionString).")
            db = try? await MongoDatabase.connect(to: connectionString)
            attempts += 1
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        guard let db else {
            throw MongoGameRepositoryError.couldNotConnect
        }

        self.db = db
        games = db["games"]
    }

    public func setGame(_ game: Game) async {
        _ = try? await games.insert(encoder.encode(game))
    }

    public func getGame(id: String) async -> Game? {
        guard let game = try? await games.findOne("gameID" == id) else {
            return nil
        }

        return try? decoder.decode(Game.self, from: game)
    }

    public func all() async -> [Game] {
        guard let games = try? await games.find().drain() else {
            return []
        }

        return games.compactMap { try? decoder.decode(Game.self, from: $0) }
    }
}

public enum MongoGameRepositoryError: Error {
    case couldNotConnect
}
