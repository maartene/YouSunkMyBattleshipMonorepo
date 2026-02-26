//
//  Game.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Maarten Engels on 31/01/2026.
//

import Foundation

public struct Game {
    public private(set) var currentPlayer: Player
    
    public let gameID: String
    public private(set) var playerBoards = [Player: Board]()
    
    public init(gameID: String? = nil, player: Player, cpu: Bool = false) {
        self.gameID = gameID ?? UUID().uuidString
        self.playerBoards = [player: Board()]
        self.currentPlayer = player
        
        if cpu {
            self.playerBoards[Player.cpu] = .makeAnotherFilledBoard()
        }
    }
    
    public init(gameID: String? = nil, player1Board: Board, player2Board: Board, player1: Player? = nil, player2: Player? = nil) {
        self.gameID = gameID ?? UUID().uuidString
        let player1 = player1 ?? Player(id: UUID().uuidString)
        let player2 = player2 ?? Player(id: UUID().uuidString)
        self.currentPlayer = player1
        
        playerBoards[player1] = player1Board
        playerBoards[player2] = player2Board
    }
    
    // MARK: Commands
    public mutating func join(_ player: Player) {
        guard canJoin else {
            print("Game is already full")
            return
        }
        
        playerBoards[player] = Board()
    }
    
    public mutating func placeShip(_ coordinates: [Coordinate], owner: Player) {
        playerBoards[owner]?.placeShip(at: coordinates)
    }
    
    public mutating func fireAt(_ coordinate: Coordinate, target: Player) {
        guard currentPlayer != target else {
            print("Its not your turn")
            return
        }
                
        playerBoards[target]?.fire(at: coordinate)
        
        if playerBoards[target]!.hitCells.count % 3 == 0 {
            currentPlayer = opponentOf(currentPlayer)!
        }
    }
    
    // MARK: Queries
    public func opponentOf(_ player: Player) -> Player? {
        playerBoards
            .map { $0.key }
            .first { $0 != player }
    }
    
    public func isDonePlacingShips(_ player: Player) -> Bool? {
        playerBoards[player]?.shipsToPlace.isEmpty
    }
    
    public func hasWonGame(_ player: Player) -> Bool? {
        guard let opponent = opponentOf(player) else {
            return nil
        }
        
        return playerBoards[opponent]?.aliveShips.isEmpty
    }
    
    public var canJoin: Bool {
        playerBoards.count == 1
    }
}

extension Game: Sendable { }
extension Game: Codable { }
