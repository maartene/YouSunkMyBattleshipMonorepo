public enum GameCommand: Codable {
    case createGame(placedShips: [PlacedShipDTO], speed: GameSpeed)
    case createGameNew(withCPU: Bool, speed: GameSpeed)
    case placeShip(ship: [Coordinate])
    case fireAt(coordinate: Coordinate)
    case load(gameID: String)
}

extension GameCommand: Equatable {
    public static func == (lhs: GameCommand, rhs: GameCommand) -> Bool {
        if case .createGame(let lhsPlacedShips, let lhsSpeed) = lhs, case .createGame(let rhsPlacedShips, let rhsSpeed) = rhs {
            return lhsPlacedShips == rhsPlacedShips && lhsSpeed == rhsSpeed
        } else if case .fireAt(let lhsCoordinate) = lhs, case .fireAt(let rhsCoordinate) = rhs {
            return lhsCoordinate == rhsCoordinate
        } else if case .load(let lhsGameID) = lhs, case .load(let rhsGameID) = rhs {
            return lhsGameID == rhsGameID
        } else {
            return false
        }
    }
}

public struct PlacedShipDTO: Codable, Sendable, Equatable {
    public let name: String
    public let coordinates: [Coordinate]

    public init(name: String, coordinates: [Coordinate]) {
        self.name = name
        self.coordinates = coordinates
    }
}

extension Board.PlacedShip {
    public func toDTO() -> PlacedShipDTO {
        PlacedShipDTO(name: ship.name, coordinates: coordinates)
    }
}

public enum GameSpeed: Codable {
    case fast
    case slow
}
