import GameRepository
import Vapor
import YouSunkMyBattleshipCommon

let app = try await Application.make(.detect())

let connectionString = ProcessInfo.processInfo.environment["CONNECTION_STRING"] ?? "mongodb://localhost:27017/game_database"

let repository = try await MongoGameRepository(connectionString: connectionString)
try configure(app, repository: repository)
try await app.execute()

func configure(_ app: Application, repository: GameRepository) throws {
    app.gameRepository = repository
    app.http.server.configuration.hostname = "0.0.0.0"
    let sendContainer = InmemorySessionContainer()
    
    app.get { req in
        return "Health check OK"
    }

    app.webSocket("game", ":playerID") { req, ws in
        req.logger.info("Connection established.")
        let playerID = req.parameters.get("playerID")!
        await setupWebSocketHandler(ws, playerID: playerID, sessionContainer: sendContainer, logger: req.logger)
    }
    app.get("games") { req in
        let games = await app.gameRepository?.all() ?? []
        return
            games
            .map { SavedGame(from: $0) }
            .sorted { $0.gameID < $1.gameID }
    }
}

func setupWebSocketHandler(_ ws: WebSocket, playerID: String, sessionContainer: SessionContainer, logger: Logger) async {
    let player = Player(id: playerID)
    await sessionContainer.register(sendFunction: { data in
        ws.send(data, promise: nil)
    }, for: player)
    let gameService = GameService(repository: app.gameRepository!, sessionContainer: sessionContainer, owner: player, bot: RandomBot(), logger: logger)
    ws.send("Welcome!".data(using: .utf8)!)

    ws.onBinary { ws, data in
        await receiveData(Data(buffer: data), on: ws, gameService: gameService)
    }

    ws.onText { ws, text in
        guard let data = text.data(using: .utf8) else { return }
        await receiveData(data, on: ws, gameService: gameService)
    }

    ws.onClose.whenComplete { _ in
        logger.info("Connection to player \(playerID) closed.")
    }

    @Sendable func receiveData(_ data: Data, on webSocket: WebSocket, gameService: GameService)
        async
    {
        do {
            try await gameService.receive(data)
        } catch {
            logger.warning("Error while receiving data: \(error)")
        }
    }
}

extension GameState: @retroactive Content {}
extension SavedGame: @retroactive Content {}

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
