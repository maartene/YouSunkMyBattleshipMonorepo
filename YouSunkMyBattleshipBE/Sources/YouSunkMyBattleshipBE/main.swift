import Vapor
import YouSunkMyBattleshipCommon

let app = try await Application.make(.detect())
try configure(app)
try await app.execute()

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
            await receiveData(Data(buffer: data), on: ws, gameService: gameService)
        }
        
        ws.onText { ws, text in
            guard let data = text.data(using: .utf8) else { return }
            await receiveData(data, on: ws, gameService: gameService)
        }

        func receiveData(_ data: Data, on webSocket: WebSocket, gameService: GameService) async {
        do {
            try await gameService.receive(data)
            let gameState = try await gameService.getGameState()
            try webSocket.send(JSONEncoder().encode(gameState))
        } catch {
            print("Error while receiving data: \(error)")
        }
    }
    }
}

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
