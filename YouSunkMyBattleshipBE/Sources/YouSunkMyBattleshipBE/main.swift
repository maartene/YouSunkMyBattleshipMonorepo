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
        let gameService = GameService(repository: app.gameRepository!)
        ws.send("Welcome!".data(using: .utf8)!)
        
        ws.onBinary { ws, data in
            do {
                try await gameService.receive(Data(buffer: data))
                let gameState = await gameService.getGameState()
                try ws.send(JSONEncoder().encode(gameState))
            } catch {
                print("Error while receiving data: \(error)")
            }
        }
        
        ws.onText { ws, text in
            do {
                guard let data = text.data(using: .utf8) else { return }
                try await gameService.receive(data)
                let gameState = await gameService.getGameState()
                try ws.send(JSONEncoder().encode(gameState))
            } catch {
                print("Error while receiving data: \(error)")
            }
        }
        
    }

    app.get("gameState") { req in
        guard let board1 = await app.gameRepository?.getBoard(for: .player1) else {
            throw Abort(.notFound)
        }

        let board1Cells = board1.cells.map { row in
            row.map { cell in
                switch cell {
                case .ship: "🚢"
                default: "🌊"
                }
            }
        }

        guard let board2 = await app.gameRepository?.getBoard(for: .player2) else {
            throw Abort(.notFound)
        }

        let board2Cells = board2.cells.map { row in
            row.map { cell in
                switch cell {
                case .miss: "❌"
                case .hitShip: "💥"
                case .destroyedShip: "🔥"
                default: "🌊"
                }
            }
        }

        let shipsToDestroy = board2.aliveShips.count
        let state = shipsToDestroy == 0 ? GameState.State.finished : .play

        let gameState = GameState(
            cells: [
                .player1: board1Cells,
                .player2: board2Cells,
            ],
            shipsToDestroy: shipsToDestroy,
            state: state
        )

        return gameState
    }

    app.post("fire") { req in
        let coordinate = try req.content.decode(Coordinate.self)

        guard var board = await app.gameRepository?.getBoard(for: .player2) else {
            throw Abort(.notFound)
        }

        board.fire(at: coordinate)
        await app.gameRepository?.setBoard(board, for: .player2)

        return Response(status: .created)
    }

    app.get("shipAt", ":coordinate") { req in
        let coordinateString = try req.parameters.require("coordinate")
        let coordinate = Coordinate(coordinateString)

        guard let board = await app.gameRepository?.getBoard(for: .player2) else {
            throw Abort(.notFound)
        }

        let shipName =
            board.destroyedShips.first { $0.coordinates.contains(coordinate) }?.ship.name ?? ""
        return shipName
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
