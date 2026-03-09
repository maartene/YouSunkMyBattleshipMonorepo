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
    
    app.get("statistics", ":playerID") { req in
        let playerID = req.parameters.get("playerID")!
        let games = await repository.all()
        
        for game in games {
            print(game.playerBoards.keys.sorted(by: { $0.id < $1.id}), game.hasFinished, game.hasWonGame(.cpu) ?? "other player")
        }
        
        let playerGames = games
            .filter { game in
                game.playerBoards.keys.contains { player in
                    player.id == playerID
                }
            }
                
        return try CalculateStatistics().calculateStatisticsFor(playerID, in: playerGames)
    }
}

extension Player: CustomStringConvertible {
    public var description: String {
        id
    }
}

extension PlayerStats: @retroactive Content { }

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
