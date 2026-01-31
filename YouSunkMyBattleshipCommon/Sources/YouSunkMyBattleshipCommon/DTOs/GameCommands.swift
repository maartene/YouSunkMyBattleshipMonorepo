public enum GameCommand: Codable {
    case createBoard(placedShips: [PlacedShipDTO])
}
