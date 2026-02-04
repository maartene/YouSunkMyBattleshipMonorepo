public enum GameCommand: Codable {
    case createBoard(placedShips: [PlacedShipDTO], gameID: String)
    case fireAt(coordinate: Coordinate)
}

extension GameCommand: Equatable {
    public static func == (lhs: GameCommand, rhs: GameCommand) -> Bool {
        if case .createBoard(let lhsPlacedShips, let lhsGameID) = lhs, case .createBoard(let rhsPlacedShips, let rhsGameID) = rhs {
            return lhsPlacedShips == rhsPlacedShips && lhsGameID == rhsGameID
        } else if case .fireAt(let lhsCoordinate) = lhs, case .fireAt(let rhsCoordinate) = rhs {
            return lhsCoordinate == rhsCoordinate
        } else {
            return false
        }
    }
}
