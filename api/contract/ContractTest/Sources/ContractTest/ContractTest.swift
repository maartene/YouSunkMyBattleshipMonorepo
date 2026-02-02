import WSDataProvider
import YouSunkMyBattleshipCommon
import Foundation

actor ContractTest {
    private let dataProvider: WSDataProvider
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var currentGameState: GameState?
    private var availableMoves = Set<Coordinate>()
    
    init() async {
        dataProvider = await WSDataProvider(url: URL(string: "ws://localhost:8080/game")!)
        await dataProvider.register(onReceive: onReceive)
        
        for y in 0 ..< Board.rows.count {
            for x in 0 ..< Board.columns.count {
                availableMoves.insert(Coordinate(x: x, y: y))
            }
        }
    }
    
    func run() async throws {
        let localBoard = Board.makeFilledBoard()
        let placedShips = localBoard.placedShips.map { $0.toDTO() }
        let createBoardCommand = GameCommand.createBoard(placedShips: placedShips)
        
        try await dataProvider.send(data: createBoardCommand.toData(using: encoder))
        
        while currentGameState?.state != .finished {
            try await Task.sleep(nanoseconds: 1_000_000)
            
            if let currentGameState, currentGameState.state == .play, currentGameState.currentPlayer == .player1 {
                
                guard let move = availableMoves.randomElement() else {
                    print("No more moves to make")
                    return
                }
                
                availableMoves.remove(move)
                
                let fireCommand = GameCommand.fireAt(coordinate: move)
                try await dataProvider.send(data: fireCommand.toData(using: encoder))
            }
        }
        
        print("Game finished")
    }
    
    func onReceive(_ data: Data) {
        currentGameState = try? decoder.decode(GameState.self, from: data)
        
        if let currentGameState {
            print(currentGameState)
        }
    }
}

extension Encodable {
    func toData(using encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
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
