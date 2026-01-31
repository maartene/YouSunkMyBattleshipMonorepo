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

    func getGameState() async -> GameState {
        let board1 = await repository.getBoard(for: .player1)?.toStringsAsPlayerBoard()
        let board2 = await repository.getBoard(for: .player2)?.toStringsAsTargetBoard()
        
        return GameState(cells: [.player1: board1 ?? [], .player2: board2 ?? []], state: .play, lastMessage: lastMessage)
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
        case .fireAt(let coordinate):
            guard var board = await repository.getBoard(for: .player2) else {
                throw GameServiceError.boardNotFound
            }
            
            board.fire(at: coordinate)
            
            if board.cells[coordinate.y][coordinate.x] == .hitShip {
                lastMessage = "Hit!"
            } else {
                lastMessage = "Miss!"
            }
            await repository.setBoard(board, for: .player2)
        }
    }
}

enum GameServiceError: Error {
    case invalidBoard
    case boardNotFound
}
