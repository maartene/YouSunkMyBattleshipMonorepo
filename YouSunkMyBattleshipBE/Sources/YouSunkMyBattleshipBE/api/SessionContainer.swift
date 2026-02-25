//
//  SessionContainer.swift
//  YouSunkMyBattleshipBE
//
//  Created by Engels, Maarten MAK on 25/02/2026.
//

import Foundation
import YouSunkMyBattleshipCommon

protocol SessionContainer: Actor {
    func register(sendFunction: @escaping (Data) -> Void, for player: Player)
    func sendGameState(to player: Player, _ event: GameState)
}

actor InmemorySessionContainer: SessionContainer {
    let encoder = JSONEncoder()
    
    private var senders: [Player: (Data) -> Void] = [:]
    
    func register(sendFunction: @escaping (Data) -> Void, for player: Player) {
        senders[player] = sendFunction
    }
    
    func sendGameState(to player: Player, _ event: GameState) {
        do {
            senders[player]?(try encoder.encode(event))
        } catch {
            print("Failed to encode state: \(error)")
        }
    }
}
