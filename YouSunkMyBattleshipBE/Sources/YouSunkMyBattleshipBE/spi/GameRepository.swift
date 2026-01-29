//
//  GameRepository.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import YouSunkMyBattleshipCommon

protocol GameRepository: Sendable {
    func setBoard(_ board: Board, for player: Player) async
    func getBoard(for player: Player) async -> Board?
}

actor InmemoryGameRepository: GameRepository {
    private var boards: [Player: Board] = [.player2: Board.makeAnotherFilledBoard()]
    
    func setBoard(_ board: Board, for player: Player) async {
        boards[player] = board
    }
    
    func getBoard(for player: Player) async -> Board? {
        boards[player]
    }
}
