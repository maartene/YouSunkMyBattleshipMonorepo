//
//  Bot.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Engels, Maarten MAK on 31/01/2026.
//

import Foundation

public protocol Bot {
    func getNextMoves(board: Board) async -> [Coordinate]
}

public struct ThinkingBot: Bot {
    private let smarts: TimeInterval
    
    public init(smarts: TimeInterval = 0.5) {
        self.smarts = smarts
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
        
        try? await Task.sleep(nanoseconds:  UInt64(1_000_000_000 * smarts))
        
        return chosenCells
    }
}
