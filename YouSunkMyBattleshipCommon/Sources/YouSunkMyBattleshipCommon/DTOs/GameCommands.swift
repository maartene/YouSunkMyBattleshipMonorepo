public enum GameCommand: Codable {
    case createBoard(placedShips: [PlacedShipDTO])
    case fireAt(coordinate: Coordinate)
}
