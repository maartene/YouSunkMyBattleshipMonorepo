import Foundation
import LCLWebSocket
import NIO
import YouSunkMyBattleshipCommon

final class Box<T: Sendable>: @unchecked Sendable {
    private(set) var value: T

    init(value: T) {
        self.value = value
    }

    func set(_ newValue: T) {
        self.value = newValue
    }
}

@MainActor
final class GamePlayer {
    enum PlayerState {
        case idle
        case connecting
        case connected
        case creatingGame
        case placingShips
        case playing
        case finished
    }
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let currentGameState = Box<GameState?>(value: nil)
    let config: LCLWebSocket.Configuration
    let hostname: String
    let port: String
    let player: Player
    var state: PlayerState = .idle
    var client: WebSocketClient?
    let websocket = Box<WebSocket?>(value: nil)
    let locked = Box(value: false)
    var availableMoves = Set<Coordinate>()

    
    private func setState(_ newState: PlayerState) {
        self.state = newState
    }
    
    init(playerID: String, config: LCLWebSocket.Configuration, hostname: String, port: String) {
        self.config = config
        self.hostname = hostname
        self.port = port
        self.player = Player(id: playerID)
        var client = LCLWebSocket.client()
        
        client.onOpen { ws in
            self.websocket.set(ws)
            Task {
                await self.setState(.connected)
            }
        }

        client.onBinary { websocket, binary in
            if let state = try? self.decoder.decode(GameState.self, from: binary) {
                self.currentGameState.set(state)
                self.locked.set(false)
            }
        }

        client.onText { websocket, text in
            print("received text: \(text)")
        }

        client.onError { error in
            fatalError("Received error: \(error)")
        }
        
        self.client = client
        
        for y in 0..<Board.rows.count {
            for x in 0..<Board.columns.count {
                availableMoves.insert(Coordinate(x: x, y: y))
            }
        }
    }
    
    func act() async throws {
        switch state {
        case .idle:
            connect()
        case .connecting:
            break
        case .connected:
            try createGame()
        case .creatingGame:
            checkCreatedGame()
        case .placingShips:
            try await placeShips()
        case .playing:
            try tryPlay()
        case .finished:
            break
        }
    }
    
    func connect() {
        _ = client?.connect(to: "ws://\(hostname):\(port)/game/\(player.id)", configuration: config)
        state = .connecting
    }
    
    func createGame() throws {
        let createGameCommand = GameCommand.createGameNew(withCPU: true, speed: .fast)
        try websocket.value?.send(
            createGameCommand.toByteBuffer(using: encoder), opcode: .binary, promise: nil)
        state = .creatingGame
    }
    
    func checkCreatedGame() {
        if currentGameState.value != nil {
            state = .placingShips
        }
    }
    
    func placeShips() async throws {
        if currentGameState.value?.state == .play {
            state = .playing
            return
        }
        
        guard currentGameState.value?.state == .placingShips else {
            return
        }
        
        guard locked.value == false else {
            return
        }
        
        locked.set(true)
        
        let board = Board.makeFilledBoard()
        
        for ship in board.placedShips {
            let placeShipCommand = GameCommand.placeShip(
                ship: ship.coordinates)
            try websocket.value?.send(
                placeShipCommand.toByteBuffer(using: encoder), opcode: .binary, promise: nil)
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    func tryPlay() throws {
        guard let gameState = currentGameState.value else {
            return
        }
        
        guard gameState.state == .play else {
            print("Game finished!")
            state = .finished
            return
        }
        
        guard gameState.currentPlayer == player else {
            return
        }
        
        guard locked.value == false else {
            return
        }
        
        locked.set(true)
        
        if let move = availableMoves.randomElement() {
            availableMoves.remove(move)

            let fireCommand = GameCommand.fireAt(coordinate: move)
            try websocket.value?.send(
                fireCommand.toByteBuffer(using: encoder), opcode: .binary, promise: nil)
        } else {
            print("No more moves to make")
        }
    }
}

@MainActor
final class ContractTest: Sendable {
    let player1: GamePlayer
    
    init(hostname: String = "127.0.0.1", port: String = "8080") {
        let config = LCLWebSocket.Configuration(
            maxFrameSize: 1 << 16,
            autoPingConfiguration: .enabled(pingInterval: .seconds(4), pingTimeout: .seconds(10)),
            leftoverBytesStrategy: .forwardBytes
        )
        self.player1 = GamePlayer(playerID: "Player_1", config: config, hostname: hostname, port: port)
    }

    func run() async throws {
        while player1.state != .finished {
            try await player1.act()
            print(gameStateToString(player1: player1))
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        print("Game finished")

    }
    
    func gameStateToString(player1: GamePlayer) -> String {
        guard let gameState = player1.currentGameState.value else {
            return "Gamestate not yet initialized"
        }
        
        var result = "State: \(gameState.state)\n"
        result += "Current player: \(gameState.currentPlayer)\n"
        result += "Ships to destroy: \(gameState.shipsToDestroy)\n"

        result += "Player 1             Player 2\n"

        let player1Cells = gameState.cells[player1.player]!
        let player2Cells = gameState.cells.first { $0.key != player1.player }!.value

        for y in 0..<Board.rows.count {
            var line = ""
            for x in 0..<Board.columns.count {
                let coordinate = Coordinate(x: x, y: y)
                line += player1Cells[coordinate.y][coordinate.x]
            }

            line += " "

            for x in 0..<Board.columns.count {
                let coordinate = Coordinate(x: x, y: y)
                line += player2Cells[coordinate.y][coordinate.x]
            }

            result += line + "\n"
        }
        result += "\(gameState.lastMessage)\n"
        return result
    }

}

extension Encodable {
    func toByteBuffer(using encoder: JSONEncoder) throws -> ByteBuffer {
        let data = try encoder.encode(self)
        return ByteBuffer(data: data)
    }
}
