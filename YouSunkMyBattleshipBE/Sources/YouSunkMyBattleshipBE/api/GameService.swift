//
//  GameService.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//

import Vapor
import YouSunkMyBattleshipCommon

final class GameService {
    let repository: GameRepository
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    private var lastMessage = "Play!"

    init(repository: GameRepository) {
        self.repository = repository
    }

    func receive(_ data: Data) async throws {
        let command = try decoder.decode(GameCommand.self, from: data)
        try await processCommand(command)
    }

    func getGameState() async throws -> GameState {
        guard let game = await repository.getGame() else {
            throw GameServiceError.gameNotFound
        }
        
        let board1 = game.player1Board
        let board2 = game.player2Board

        let shipsToDestroy = board2.aliveShips.count
        let state = shipsToDestroy == 0 ? GameState.State.finished : .play

        return GameState(
            cells: [
                .player1: board1.toStringsAsPlayerBoard(),
                .player2: board2.toStringsAsTargetBoard(),
            ],
            shipsToDestroy: shipsToDestroy,
            state: state,
            lastMessage: lastMessage
        )
    }

    private func processCommand(_ command: GameCommand) async throws {
        switch command {
        case .createBoard(let placedShips):
            var board = Board()
            for ship in placedShips {
                board.placeShip(at: ship.coordinates)
            }

            guard board.placedShips.count == 5 else {
                throw GameServiceError.invalidBoard
            }

            await repository.setGame(Game(player1Board: board, player2Board: .makeAnotherFilledBoard()))
        case .fireAt(let coordinate):
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
            }

            await repository.setGame(game)
        }
    }

    func cpuFires() async throws {
        guard var game = await repository.getGame() else {
            throw GameServiceError.gameNotFound
        }

        let hitCoordinates = [Coordinate("B2"), Coordinate("C2"), Coordinate("A1")]
        for hitCoordinate in hitCoordinates {
            game.fireAt(hitCoordinate, target: .player1)
        }

        lastMessage = "CPU fires at B2, C2 and A1"

        await repository.setGame(game)
    }
}

enum GameServiceError: Error {
    case invalidBoard
    case boardNotFound
    case gameNotFound
}
