//
//  AcceptanceTests.swift
//  YouSunkMyBattleshipTests
//
//  Created by Maarten Engels on 27/11/2025.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import Combine

/// As a player
/// I want to see an empty game board
/// So that I can visualize the battlefield
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Game Board Initialization` {
    var view = GameView(viewModel: NewClientViewModel(dataProvider: DummyDataProvider()))
    
    @Test mutating func `Scenario: Player views empty board`() throws {
        `Given I start a new Battleship game`()
        `When the game initializes`()
        
        try `Then I see a 10x10 grid filled with 🌊 emojis`()
        try `And the grid has row labels A-J and column labels 1-10`()
        try `And all five ships to be placed are shown`()
    }
}

// MARK: Steps
extension `Feature: Game Board Initialization` {
    private func `Given I start a new Battleship game`() { }
    private func `When the game initializes`() { }

    private func `Then I see a 10x10 grid filled with 🌊 emojis`() throws {
        let gameBoards = try view.inspect().findAll(GameBoardView.self)
        #expect(gameBoards.count == 1)
        
        let playerBoard = gameBoards[0]
        let rows = playerBoard.findAll(BoardRowView.self)
        #expect(rows.count == 10)
        
        for row in rows {
            let columns = row.findAll(CellView.self)
            #expect(columns.count == 10)
            
            for cell in columns {
                #expect(try cell.geometryReader().text().string() == "🌊")
            }
        }
    }

    private func `And the grid has row labels A-J and column labels 1-10`() throws {
        try validateRowLabels()
        try validateColumnLabels()
        
        func validateRowLabels() throws {
            let expectedRowLabels = [
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J"
            ]
            
            let rowLabels = try getPlayerBoard(from: view)
                .findAll(BoardRowView.self)
                .map { try $0.text(0).string() }
            
            #expect(rowLabels == expectedRowLabels)
        }
        
        func validateColumnLabels() throws {
            let expectedColumnLabels = [
                "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
            ]
            
            let columnLabels = try getPlayerBoard(from: view)
                .grid(0)
                .gridRow(0)
                .forEach(1)
                .map { try $0.text().string() }
            
            #expect(columnLabels == expectedColumnLabels)
        }
    }
    
    private func `And all five ships to be placed are shown`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        
        #expect(try inspectedView.text().string().contains("Carrier(5)"))
        #expect(try inspectedView.text().string().contains("Battleship(4)"))
        #expect(try inspectedView.text().string().contains("Cruiser(3)"))
        #expect(try inspectedView.text().string().contains("Submarine(3)"))
        #expect(try inspectedView.text().string().contains("Destroyer(2)"))
    }
}

