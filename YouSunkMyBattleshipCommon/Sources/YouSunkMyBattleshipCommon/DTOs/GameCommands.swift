public enum GameCommand: Codable {
    case createGame(withCPU: Bool, speed: GameSpeed)
    case placeShip(ship: [Coordinate])
    case fireAt(coordinate: Coordinate)
    case load(gameID: String)
}

extension GameCommand: Equatable { }

public enum GameSpeed: Codable {
    case fast
    case slow
}
