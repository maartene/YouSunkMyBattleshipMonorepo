//
//  SavedGame.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Maarten Engels on 24/02/2026.
//

import Foundation

public struct SavedGame: Codable {
    public let gameID: String
    public let players: [String]
    public let canJoin: Bool
    
    public init(from game: Game) {
        self.gameID = game.gameID
        self.players = game.playerBoards
            .map { $0.key }
            .map { $0.id }
        self.canJoin = game.canJoin
    }
}

extension SavedGame: Sendable { }
extension SavedGame: Equatable { }
