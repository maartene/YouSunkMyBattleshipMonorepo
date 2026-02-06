public enum GameCommand: Codable {
    case createGame(placedShips: [PlacedShipDTO], speed: GameSpeed)
    case fireAt(coordinate: Coordinate)
}

extension GameCommand: Equatable {
    public static func == (lhs: GameCommand, rhs: GameCommand) -> Bool {
        if case .createGame(let lhsPlacedShips, let lhsSpeed) = lhs, case .createGame(let rhsPlacedShips, let rhsSpeed) = rhs {
            return lhsPlacedShips == rhsPlacedShips && lhsSpeed == rhsSpeed
        } else if case .fireAt(let lhsCoordinate) = lhs, case .fireAt(let rhsCoordinate) = rhs {
            return lhsCoordinate == rhsCoordinate
        } else {
            return false
        }
    }
}
