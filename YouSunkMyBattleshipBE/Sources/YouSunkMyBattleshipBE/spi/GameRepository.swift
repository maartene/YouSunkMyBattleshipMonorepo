//
//  GameRepository.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import YouSunkMyBattleshipCommon
import GameRepository

actor InmemoryGameRepository: GameRepository {
    private var storage = [String: Game]()
    
    func setGame(_ game: Game) async {
        self.storage[game.gameID] = game
    }
    
    func getGame(id: String) async -> Game? {
        self.storage[id]
    }
    
    func all() async -> [Game] {
        Array(storage.values)
    }
}
