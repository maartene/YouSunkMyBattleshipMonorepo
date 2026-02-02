//
//  GameRepository.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import YouSunkMyBattleshipCommon

protocol GameRepository: Sendable {
    func setGame(_ game: Game) async
    func getGame() async -> Game?
}

actor InmemoryGameRepository: GameRepository {
    private var game: Game?
    func setGame(_ game: Game) async {
        self.game = game
    }
    
    func getGame() async -> Game? {
        self.game
    }
}
