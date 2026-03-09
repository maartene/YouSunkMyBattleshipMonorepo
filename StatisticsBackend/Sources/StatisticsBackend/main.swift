import GameRepository
import Vapor
import YouSunkMyBattleshipCommon

let app = try await Application.make(.detect())
let connectionString =
    ProcessInfo.processInfo.environment["CONNECTION_STRING"]
    ?? "mongodb://localhost:27017/game_database"

let repository = try await MongoGameRepository(connectionString: connectionString)
try configure(app, repository: repository)

try await app.execute()

func configure(_ app: Application, repository: GameRepository) throws {
    app.gameRepository = repository
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8081
    
    app.get { req in
        return "Health check OK"
    }
}

struct GameRepositoryKey: StorageKey {
    typealias Value = GameRepository
}

extension Application {
    var gameRepository: GameRepository? {
        get {
            self.storage[GameRepositoryKey.self]
        }
        set {
            self.storage[GameRepositoryKey.self] = newValue
        }
    }
}
