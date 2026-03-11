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
    public let isFinished: Bool
    
    public init(gameID: String, players: [String], canJoin: Bool, isFinished: Bool) {
        self.gameID = gameID
        self.players = players
        self.canJoin = canJoin
        self.isFinished = isFinished
    }
    
    public init(from game: Game) {
        self.gameID = game.gameID
        self.players = game.playerBoards
            .map { $0.key }
            .map { $0.id }
        self.canJoin = game.canJoin
        self.isFinished = game.hasFinished
    }
}

extension SavedGame: Sendable { }
extension SavedGame: Equatable { }
