public struct GameState: Codable, Sendable {
    public enum State: Codable, Sendable {
        case play
        case finished
    }
    
    public let cells: [Player: [[String]]]
    public let shipsToDestroy: Int
    public let state: State
    
    public init(cells: [Player: [[String]]] = [:], shipsToDestroy: Int = 5, state: State = .play) {
        self.cells = cells
        self.shipsToDestroy = shipsToDestroy
        self.state = state
    }
}

public struct PlacedShipDTO: Codable, Sendable {
    public let name: String
    public let coordinates: [Coordinate]

    public init(name: String, coordinates: [Coordinate]) {
        self.name = name
        self.coordinates = coordinates
    }
}

public struct BoardDTO: Codable, Sendable {
    public let placedShips: [PlacedShipDTO]

    public init(placedShips: [PlacedShipDTO]) {
        self.placedShips = placedShips
    }
}

extension Board.PlacedShip {
    func toDTO() -> PlacedShipDTO {
        PlacedShipDTO(name: ship.name, coordinates: coordinates)
    }
}

extension Board {
    public func toDTO() -> BoardDTO {
        BoardDTO(placedShips:
            self.placedShips.map { $0.toDTO() }
        )
    }
}

extension Board {
    public func toStringsAsPlayerBoard() -> [[String]] {
        return cells.map { row in
            row.map { cell in
                switch cell {
                case .empty: "🌊"
                case .ship: "🚢"
                default: " "
                }
            }
        }
    }
}
