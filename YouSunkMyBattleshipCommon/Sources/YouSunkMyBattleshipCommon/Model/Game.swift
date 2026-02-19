//
//  Game.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Maarten Engels on 31/01/2026.
//

import Foundation

public struct Game {
    public private(set) var currentPlayer = Player.player1
    
    public var player1Board: Board {
        playerBoards[.player1]!
    }
    
    public var player2Board: Board {
        playerBoards[.player2]!
    }
    
    public let gameID: String
    private var playerBoards = [Player: Board]()
    
    public init(gameID: String? = nil, player1Board: Board, player2Board: Board) {
        self.gameID = gameID ?? UUID().uuidString
        
        playerBoards[.player1] = player1Board
        playerBoards[.player2] = player2Board
    }
    
    public mutating func fireAt(_ coordinate: Coordinate, target: Player) {
        guard currentPlayer != target else {
            print("Its not your turn")
            return
        }
        
        if target == .player1 {
            playerBoards[target]?.fire(at: coordinate)
            
            if player1Board.hitCells.count % 3 == 0 {
                currentPlayer = .player1
            }
        } else {
            playerBoards[target]?.fire(at: coordinate)
            
            if player2Board.hitCells.count % 3 == 0 {
                currentPlayer = .player2
            }
        }
    }
}

extension Game: Sendable { }
extension Game: Codable { }
