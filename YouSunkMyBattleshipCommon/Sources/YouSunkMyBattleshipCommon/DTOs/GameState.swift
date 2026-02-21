public struct GameState: Codable, Sendable {
    public enum State: Codable, Sendable {
        case placingShips
        case play
        case finished
    }
    
    public let cells: [Player: [[String]]]
    public let shipsToDestroy: Int
    public let state: State
    public let currentPlayer: Player
    
    public init(cells: [Player: [[String]]] = [:], shipsToDestroy: Int = 5, state: State = .placingShips, lastMessage: String = "Play!", currentPlayer: Player) {
        self.cells = cells
        self.shipsToDestroy = shipsToDestroy
        self.state = state
        self.lastMessage = lastMessage
        self.currentPlayer = currentPlayer
    }
    
    public let lastMessage: String
}

extension Board {
    public func toStringsAsPlayerBoard() -> [[String]] {
        return cells.map { row in
            row.map { cell in
                switch cell {
                case .empty: "🌊"
                case .ship: "🚢"
                case .destroyedShip: "🔥"
                case .hitShip: "💥"
                case .miss: "❌"
                }
            }
        }
    }
    
    public func toStringsAsTargetBoard() -> [[String]] {
        cells.map { row in
            row.map { cell in
                switch cell {
                case .miss: "❌"
                case .hitShip: "💥"
                case .destroyedShip: "🔥"
                default: "🌊"
                }
            }
        }
    }
}
