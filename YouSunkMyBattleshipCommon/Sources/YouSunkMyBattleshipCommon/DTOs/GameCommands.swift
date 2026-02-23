public enum GameCommand: Codable {
    case createGameNew(withCPU: Bool, speed: GameSpeed)
    case placeShip(ship: [Coordinate])
    case fireAt(coordinate: Coordinate)
    case load(gameID: String)
}

extension GameCommand: Equatable {
    public static func == (lhs: GameCommand, rhs: GameCommand) -> Bool {
        if case .fireAt(let lhsCoordinate) = lhs, case .fireAt(let rhsCoordinate) = rhs {
            return lhsCoordinate == rhsCoordinate
        } else if case .load(let lhsGameID) = lhs, case .load(let rhsGameID) = rhs {
            return lhsGameID == rhsGameID
        } else if case .placeShip(let lhsCoordinates) = lhs, case .placeShip(let rhsCoordinates) = rhs {
            return lhsCoordinates == rhsCoordinates
        } else if case .createGameNew(let lhsWithCPU, let lhsSpeed) = lhs, case .createGameNew(let rhsWithCPU, let rhsSpeed) = rhs {
            return lhsWithCPU == rhsWithCPU && lhsSpeed == rhsSpeed
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
