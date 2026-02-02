import YouSunkMyBattleshipCommon
import Foundation
import LCLWebSocket
import NIO

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

        let currentGameState = Box(value: GameState())
        let websocket = Box<WebSocket?>(value: nil)
        let locked = Box(value: false)
        
        for y in 0 ..< Board.rows.count {
            for x in 0 ..< Board.columns.count {
                availableMoves.insert(Coordinate(x: x, y: y))
            }
        }
        
        var client = LCLWebSocket.client()
        client.onOpen { ws in
            let localBoard = Board.makeFilledBoard()
            let placedShips = localBoard.placedShips.map { $0.toDTO() }
            let createBoardCommand = GameCommand.createBoard(placedShips: placedShips)
            try? ws.send(createBoardCommand.toByteButffer(using: self.encoder), opcode: .binary, promise: nil)
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

        _ = client.connect(to: "ws://\(hostname):\(port)/game", configuration: config)
        
        while currentGameState.value.state != .finished {
            try await Task.sleep(nanoseconds: 10_000_000)
            if locked.value == false, currentGameState.value.state == .play, currentGameState.value.currentPlayer == .player1 {
                
                locked.set(true)
                
                guard let move = availableMoves.randomElement() else {
                    fatalError("No more moves to make")
                }
                
                availableMoves.remove(move)
                
                let fireCommand = GameCommand.fireAt(coordinate: move)
                try websocket.value?.send(fireCommand.toByteButffer(using: encoder), opcode: .binary, promise: nil)
            }
        }
        
        print("Game finished")
    }
}

extension Encodable {
    func toByteButffer(using encoder: JSONEncoder) throws -> ByteBuffer {
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
        for y in 0 ..< Board.rows.count {
            var line = ""
            for x in 0 ..< Board.columns.count {
                let coordinate = Coordinate(x: x, y: y)
                line += cells[.player1, default: []][coordinate.y][coordinate.x]
            }
            
            line += " "
            
            for x in 0 ..< Board.columns.count {
                let coordinate = Coordinate(x: x, y: y)
                line += cells[.player2, default: []][coordinate.y][coordinate.x]
            }
            
            result += line + "\n"
        }
        result += "\(lastMessage)\n"
        
        
        return result
    }
}
