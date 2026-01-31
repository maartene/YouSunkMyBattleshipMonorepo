import Vapor
import YouSunkMyBattleshipCommon

let app = try await Application.make(.detect())

func configure(_ app: Application) throws {
    app.gameRepository = InmemoryGameRepository()
    app.http.server.configuration.hostname = "0.0.0.0"
    
    app.get { req in
        return "Health check OK"
    }

    app.webSocket("game") { req, ws in
        let gameService = GameService(repository: app.gameRepository!, bot: ThinkingBot(), ws: ws)
        ws.send("Welcome!".data(using: .utf8)!)
        
        ws.onBinary { ws, data in
            do {
                try await gameService.receive(Data(buffer: data))
                let gameState = try await gameService.getGameState()
                try ws.send(JSONEncoder().encode(gameState))
            } catch {
                print("Error while receiving data: \(error)")
            }
        }
        
        ws.onText { ws, text in
            do {
                guard let data = text.data(using: .utf8) else { return }
                try await gameService.receive(data)
                let gameState = try await gameService.getGameState()
                try ws.send(JSONEncoder().encode(gameState))
            } catch {
                print("Error while receiving data: \(error)")
            }
        }
    }
}

try configure(app)
try await app.execute()

extension GameState: @retroactive Content {}

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
