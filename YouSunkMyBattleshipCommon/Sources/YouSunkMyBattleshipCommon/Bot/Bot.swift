//
//  Bot.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Engels, Maarten MAK on 31/01/2026.
//

import Foundation

public protocol Bot: Sendable {
    func getNextMoves(board: Board) async -> [Coordinate]
}

public struct RandomBot: Bot {
    public init() {
        
    }
    
    public func getNextMoves(board: Board) async -> [Coordinate] {
        let cells = (0 ..< board.height).flatMap { y in
            (0 ..< board.width).map { x in
                Coordinate(x: x, y: y)
            }
        }
        
        var availableCells = cells.filter { board.hitCells.contains($0) == false }
        
        availableCells.shuffle()
        
        let cellsToChoose = min(3, availableCells.count)
        
        var chosenCells: [Coordinate] = []
        for _ in 0 ..< cellsToChoose {
            chosenCells.append(availableCells.removeLast())
            
        }
        
        return chosenCells
    }
}
