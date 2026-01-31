//
//  GameService.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//

import Vapor
import YouSunkMyBattleshipCommon

final class GameService: Sendable {
    let repository: GameRepository
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init(repository: GameRepository) {
        self.repository = repository
    }

    func receive(_ data: Data) async throws {
        let command = try decoder.decode(GameCommand.self, from: data)
        try await processCommand(command)
    }

    func getGameState() async -> GameState {
        let board1 = await repository.getBoard(for: .player1)?.toStringsAsPlayerBoard()
        let board2 = Array(repeating: Array(repeating: "🌊", count: 10), count: 10)  // Placeholder for player 2 board
        return GameState(cells: [.player1: board1 ?? [], .player2: board2], state: .play)
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

            await repository.setBoard(board, for: .player1)
            await repository.setBoard(.makeAnotherFilledBoard(), for: .player2)
        }
    }
}

enum GameServiceError: Error {
    case invalidBoard
}
