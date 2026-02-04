//
//  Game.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Maarten Engels on 31/01/2026.
//

import Foundation

public struct Game {
    public private(set) var currentPlayer = Player.player1
    
    public private(set) var player1Board: Board
    public private(set) var player2Board: Board
    public let gameID: String
    
    public init(gameID: String? = nil, player1Board: Board, player2Board: Board) {
        self.player1Board = player1Board
        self.player2Board = player2Board
        self.gameID = gameID ?? UUID().uuidString
    }
    
    public mutating func fireAt(_ coordinate: Coordinate, target: Player) {
        guard currentPlayer != target else {
            print("Its not your turn")
            return
        }
        
        if target == .player1 {
            player1Board.fire(at: coordinate)
            
            if player1Board.hitCells.count % 3 == 0 {
                currentPlayer = .player1
            }
        } else {
            player2Board.fire(at: coordinate)
            
            if player2Board.hitCells.count % 3 == 0 {
                currentPlayer = .player2
            }
        }
    }
}

extension Game: Sendable { }
