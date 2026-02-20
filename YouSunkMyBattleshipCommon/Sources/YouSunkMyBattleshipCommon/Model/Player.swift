//
//  Player.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Engels, Maarten MAK on 28/01/2026.
//

import Foundation

public struct Player: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: String
    
    public init(id: String = UUID().uuidString) {
        self.id = id
    }
}
