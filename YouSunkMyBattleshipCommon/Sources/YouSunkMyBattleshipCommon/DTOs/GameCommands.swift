public enum GameCommand: Codable {
    case createBoard(placedShips: [PlacedShipDTO])
    case fireAt(coordinate: Coordinate)
}

extension GameCommand: Equatable {
    public static func == (lhs: GameCommand, rhs: GameCommand) -> Bool {
        if case .createBoard(let lhsPlacedShips) = lhs, case .createBoard(let rhsPlacedShips) = rhs {
            return lhsPlacedShips == rhsPlacedShips
        } else if case .fireAt(let lhsCoordinate) = lhs, case .fireAt(let rhsCoordinate) = rhs {
            return lhsCoordinate == rhsCoordinate
        } else {
            return false
        }
    }
}
