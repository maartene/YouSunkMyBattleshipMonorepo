//
//  DetectShipSinkingAcceptanceTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/01/2026.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import Combine
import YouSunkMyBattleshipCommon

/// As a player
/// I want the game to end when all ships are sunk 
/// So that a winner is declared
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Victory Condition` {
    let viewModel: ClientViewModel
    let view: GameView
    
    init() async {
        viewModel = ClientViewModel(dataProvider: MockDataProvider(dataToReceiveOnSend: victoryState))
        await completePlacement(on: viewModel)
        await viewModel.confirmPlacement()
        view = GameView(viewModel: viewModel)
    }
    
    @Test func `Scenario: Player restarts the game`() async throws {
        try await `Given the game has ended`()
        try `When I tap the "New Game button`()
        try `Then a new game starts`()
    }
}

extension `Feature: Victory Condition` {
    func `Given the game has ended`() async throws {
        while viewModel.state != .finished {
            try await Task.sleep(nanoseconds: 1000)
        }
    }
    
    func `When I tap the "New Game button`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        let button = try inspectedView.find(button: "New Game")
        try button.tap()
    }
    
    func `Then a new game starts`() throws {
        let rows = try getPlayerBoard(from: view).findAll(BoardRowView.self)
        #expect(rows.count == 10)
        
        for row in rows {
            let columns = row.findAll(CellView.self)
            #expect(columns.count == 10)
            
            for cell in columns {
                #expect(try cell.text().string() == "🌊")
            }
        }
    }
}
