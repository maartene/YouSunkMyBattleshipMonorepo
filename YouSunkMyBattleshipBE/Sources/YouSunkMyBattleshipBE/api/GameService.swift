//
//  GameService.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//

import Vapor
import YouSunkMyBattleshipCommon

final class GameService {
    private let repository: GameRepository
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var lastMessage = "Play!"
    private let bot: Bot
    private let ws: WebSocket?

    init(repository: GameRepository, bot: Bot = ThinkingBot(), ws: WebSocket? = nil) {
        self.repository = repository
        self.bot = bot
        self.ws = ws
    }

    func receive(_ data: Data) async throws {
        let command = try decoder.decode(GameCommand.self, from: data)
        try await processCommand(command)
    }

    func getGameState() async throws -> GameState {
        guard let game = await repository.getGame() else {
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
        case .createBoard(let placedShips):
            try await createBoard(with: placedShips)
        case .fireAt(let coordinate):
            try await fireAt(coordinate)
        }
    }

    private func createBoard(with placedShips: [PlacedShipDTO]) async throws {
        var board = Board()
        for ship in placedShips {
            board.placeShip(at: ship.coordinates)
        }

        guard board.placedShips.count == 5 else {
            throw GameServiceError.invalidBoard
        }

        await repository.setGame(
            Game(player1Board: board, player2Board: .makeAnotherFilledBoard())
        )
    }

    private func fireAt(_ coordinate: Coordinate) async throws {
        guard var game = await repository.getGame() else {
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

        if player2Board.aliveShips.isEmpty {
            lastMessage = "🎉 VICTORY! You sank the enemy fleet! 🎉"
        } else {
            if game.currentPlayer == .player2 {
                await self.repository.setGame(game)
                let data = try await getGameState()
                try ws?.send(encoder.encode(data))

                let botCoordinates = await self.bot.getNextMoves(board: game.player1Board)
                for botCoordinate in botCoordinates {
                    game.fireAt(botCoordinate, target: .player1)
                }

                switch botCoordinates.count {
                case 1: lastMessage = "CPU fires at \(botCoordinates[0])"
                case 2: lastMessage = "CPU fires at \(botCoordinates[0]) and \(botCoordinates[1])"
                case 3:
                    lastMessage =
                        "CPU fires at \(botCoordinates[0]), \(botCoordinates[1]) and \(botCoordinates[2])"
                default: break
                }

                if game.player1Board.aliveShips.isEmpty {
                    lastMessage = "💥 DEFEAT! The CPU sank your fleet! 💥"
                }

                await self.repository.setGame(game)
            }
        }

        await repository.setGame(game)
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
