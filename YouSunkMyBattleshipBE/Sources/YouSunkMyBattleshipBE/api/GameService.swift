//
//  GameService.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//

import Vapor
import YouSunkMyBattleshipCommon

actor GameService {
    private let repository: GameRepository
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var lastMessage = "Play!"
    private let bot: Bot
    private let ws: WebSocket?
    private var speed: GameSpeed = .slow
    let gameID: String = "A game"

    init(repository: GameRepository, bot: Bot = RandomBot(), ws: WebSocket? = nil) {
        self.repository = repository
        self.bot = bot
        self.ws = ws
    }

    func receive(_ data: Data) async throws {
        let command = try decoder.decode(GameCommand.self, from: data)
        try await processCommand(command)
    }

    func getGameState() async throws -> GameState {
        guard let game = await repository.getGame(id: gameID) else {
            throw GameServiceError.gameNotFound
        }

        return GameState(
            cells: [
                .player1: game.player1Board.toStringsAsPlayerBoard(),
                .player2: game.player2Board.toStringsAsTargetBoard(),
            ],
            shipsToDestroy: game.shipsToDestroy,
            state: game.state,
            lastMessage: lastMessage,
            currentPlayer: game.currentPlayer
        )
    }

    private func processCommand(_ command: GameCommand) async throws {
        switch command {
        case .createGame(let placedShips, let speed):
            try await createGame(with: placedShips, speed: speed)
        case .load(let gameID):
            try await loadGame(gameID: gameID)
        case .fireAt(let coordinate):
            try await fireAt(coordinate)
        }
    }

    private func createGame(with placedShips: [PlacedShipDTO], speed: GameSpeed) async throws {
        var board = Board()
        for ship in placedShips {
            board.placeShip(at: ship.coordinates)
        }

        guard board.placedShips.count == 5 else {
            throw GameServiceError.invalidBoard
        }
        
        self.speed = speed

        await repository.setGame(
            Game(gameID: gameID, player1Board: board, player2Board: .makeAnotherFilledBoard())
        )
    }
    
    private func loadGame(gameID: String) async throws {
        
    }

    private func fireAt(_ coordinate: Coordinate) async throws {
        guard var game = await repository.getGame(id: gameID) else {
            throw GameServiceError.gameNotFound
        }

        game.fireAt(coordinate, target: .player2)

        let player2Board = game.player2Board

        switch player2Board.cells[coordinate.y][coordinate.x] {
        case .hitShip: lastMessage = "Hit!"
        case .destroyedShip:
            let destroyedShip = player2Board.destroyedShips.first(where: {
                $0.coordinates.contains(coordinate)
            })!
            lastMessage = "You sank the enemy \(destroyedShip.ship.name)!"
        default: lastMessage = "Miss!"
        }

        if player2Board.aliveShips.isEmpty == false {
            try await processPlayer2Turn(&game)
        } else {
            lastMessage = "🎉 VICTORY! You sank the enemy fleet! 🎉"
        }

        await repository.setGame(game)
    }

    private func processPlayer2Turn(_ game: inout Game) async throws {
        guard game.currentPlayer == .player2 else {
            return
        }

        try await saveAndSendGameState(game)

        let botCoordinates = await self.bot.getNextMoves(board: game.player1Board)
        lastMessage = getCPUFiresMessage(botCoordinates: botCoordinates)

        for botCoordinate in botCoordinates {
            try await cpuFire(at: botCoordinate, in: &game)
        }

        if game.player1Board.aliveShips.isEmpty {
            lastMessage = "💥 DEFEAT! The CPU sank your fleet! 💥"
        }

        await self.repository.setGame(game)
    }

    private func saveAndSendGameState(_ game: Game) async throws {
        await self.repository.setGame(game)
        let data = try await getGameState()
        try ws?.send(encoder.encode(data))
    }

    private func getCPUFiresMessage(botCoordinates: [Coordinate]) -> String {
        return switch botCoordinates.count {
        case 1: "CPU fires at \(botCoordinates[0])"
        case 2: "CPU fires at \(botCoordinates[0]) and \(botCoordinates[1])"
        case 3:
            "CPU fires at \(botCoordinates[0]), \(botCoordinates[1]) and \(botCoordinates[2])"
        default: ""
        }
    }

    private func cpuFire(at coordinate: Coordinate, in game: inout Game) async throws {
        try await Task.sleep(nanoseconds: speed.nanoSecondDelay)
        game.fireAt(coordinate, target: .player1)
        try await saveAndSendGameState(game)
    }

}

enum GameServiceError: Error {
    case invalidBoard
    case boardNotFound
    case gameNotFound
}

extension Game {
    var shipsToDestroy: Int {
        player2Board.aliveShips.count
    }

    var state: GameState.State {
        (shipsToDestroy == 0 || player1Board.aliveShips.isEmpty) ? .finished : .play
    }
}

extension GameSpeed {
    var nanoSecondDelay: UInt64 {
        let delay = self == .fast ? 0.1 : 0.75
        return UInt64(1_000_000_000.0 * delay)
    }
}
