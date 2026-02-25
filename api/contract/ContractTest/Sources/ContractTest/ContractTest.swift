import Foundation
import LCLWebSocket
import NIO
import YouSunkMyBattleshipCommon

@MainActor
final class ContractTest: Sendable {
    let config = LCLWebSocket.Configuration(
        maxFrameSize: 1 << 16,
        autoPingConfiguration: .enabled(pingInterval: .seconds(4), pingTimeout: .seconds(10)),
        leftoverBytesStrategy: .forwardBytes
    )
    
    let hostname: String
    let port: String
    let useCPUOpponent: Bool
    
    let player1: GamePlayer
    var player2: GamePlayer!
    
    init(hostname: String, port: String, useCPUOpponent: Bool) {
        self.hostname = hostname
        self.port = port
        self.useCPUOpponent = useCPUOpponent
        self.player1 = GamePlayer(playerID: "Player_1", config: config, hostname: hostname, port: port, useCPUOpponent: useCPUOpponent)
    }

    func run() async throws {
        if useCPUOpponent {
            print("Running with CPU opponent")
        } else {
            try await run2Players()
        }
    }
    
    func run2Players() async throws {
        var gameID: String? = nil
        print("Creating game")
        while player1.currentGameState.value?.gameID == nil {
            try await player1.act()
            print(gameStateToString(owner: player1))
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        
        gameID = player1.currentGameState.value!.gameID
        print("Game created: \(gameID!)")
        player2 = GamePlayer(playerID: "Player_2", config: config, hostname: hostname, port: port, gameID: gameID!)
        
        print("Player 2 joins game.")
        while player2.currentGameState.value?.gameID == nil {
            try await player2.act()
            print(gameStateToString(owner: player2))
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        print("Player 2 joined the game.")
        
        print("Play the game")
        while player1.state != .finished {
            try await player1.act()
            try await player2.act()
            print(gameStateToString(owner: player1))
            print(gameStateToString(owner: player2))
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        print("Game finished")
    }
    
    func gameStateToString(owner: GamePlayer) -> String {
        guard let gameState = owner.currentGameState.value else {
            return "Gamestate not yet initialized"
        }
        
        var result = "Player: \(owner.player.id)\n"
        result += "State: \(gameState.state)\n"
        result += "Current player: \(gameState.currentPlayer)\n"
        result += "Ships to destroy: \(gameState.shipsToDestroy)\n"

        result += "Owner                Opponent\n"

        let ownerCells = gameState.cells[owner.player]!
        let opponentCells = gameState.cells.first { $0.key != owner.player }!.value

        for y in 0..<Board.rows.count {
            var line = ""
            for x in 0..<Board.columns.count {
                let coordinate = Coordinate(x: x, y: y)
                line += ownerCells[coordinate.y][coordinate.x]
            }

            line += " "

            for x in 0..<Board.columns.count {
                let coordinate = Coordinate(x: x, y: y)
                line += opponentCells[coordinate.y][coordinate.x]
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
