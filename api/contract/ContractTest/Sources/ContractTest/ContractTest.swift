import Foundation
import LCLWebSocket
import NIO
import YouSunkMyBattleshipCommon

let player = Player(id: "Player_1")

final class Box<T: Sendable>: @unchecked Sendable {
    private(set) var value: T

    init(value: T) {
        self.value = value
    }

    func set(_ newValue: T) {
        self.value = newValue
    }
}

final class ContractTest: Sendable {
    let config: LCLWebSocket.Configuration
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let hostname: String
    let port: String
    

    init(hostname: String = "127.0.0.1", port: String = "8080") {
        self.hostname = hostname
        self.port = port
        config = LCLWebSocket.Configuration(
            maxFrameSize: 1 << 16,
            autoPingConfiguration: .enabled(pingInterval: .seconds(4), pingTimeout: .seconds(10)),
            leftoverBytesStrategy: .forwardBytes
        )
    }

    func run() async throws {
        var availableMoves = Set<Coordinate>()

        let currentGameState = Box(value: GameState(currentPlayer: player))
        let websocket = Box<WebSocket?>(value: nil)
        let locked = Box(value: false)

        for y in 0..<Board.rows.count {
            for x in 0..<Board.columns.count {
                availableMoves.insert(Coordinate(x: x, y: y))
            }
        }

        var client = LCLWebSocket.client()
        client.onOpen { ws in
            let localBoard = Board.makeFilledBoard()
            let placedShips = localBoard.placedShips.map { $0.toDTO() }
            let createBoardCommand = GameCommand.createGame(
                placedShips: placedShips, speed: .fast)
            try? ws.send(
                createBoardCommand.toByteBuffer(using: self.encoder), opcode: .binary, promise: nil
            )
            websocket.set(ws)
        }

        client.onBinary { websocket, binary in
            if let state = try? self.decoder.decode(GameState.self, from: binary) {
                currentGameState.set(state)
                print(currentGameState.value)
                locked.set(false)
            }
        }

        client.onText { websocket, text in
            print("received text: \(text)")
        }

        client.onError { error in
            fatalError("Received error: \(error)")
        }

        _ = client.connect(to: "ws://\(hostname):\(port)/game/\(player.id)", configuration: config)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let deadline = Date().addingTimeInterval(300)
        while currentGameState.value.state != .finished {
            guard Date() < deadline else {
                fatalError("Out of time")
            }

            try await Task.sleep(nanoseconds: 100_000_000)
            if locked.value == false, currentGameState.value.state == .play,
                currentGameState.value.currentPlayer == player
            {

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

        print("Game finished")
    }
}

extension Encodable {
    func toByteBuffer(using encoder: JSONEncoder) throws -> ByteBuffer {
        let data = try encoder.encode(self)
        return ByteBuffer(data: data)
    }
}

extension GameState: @retroactive CustomStringConvertible {
    public var description: String {
        var result = "State: \(state)\n"
        result += "Current player: \(currentPlayer)\n"
        result += "Ships to destroy: \(shipsToDestroy)\n"

        result += "Player 1             Player 2\n"

        let player1Cells = cells[player]!
        let player2Cells = cells.first { $0.key != player }!.value

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
        result += "\(lastMessage)\n"

        return result
    }
}
