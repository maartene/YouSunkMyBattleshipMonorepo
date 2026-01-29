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
        viewModel = ClientViewModel(gameService: FinishedGameService())
        addViewsToViewModel(viewModel)
        completePlacement(on: viewModel)
        await viewModel.confirmPlacement()
        view = GameView(viewModel: viewModel)
    }
    
    @Test func `Scenario: Player wins the game`() async throws {
        try await `Given only one enemy ship remains with one unhit cell`()
        try await `When I fire at the last ship's remaining cell`()
        try `Then I see "🎉 VICTORY! You sank the enemy fleet! 🎉"`()
        try `And the game ends`()
    }
    
    @Test func `Scenario: Player restarts the game`() async throws {
        try await `Given the game has ended`()
        try `When I tap the "New Game button`()
        try `Then a new game starts`()
    }
}

extension `Feature: Victory Condition` {
    func `Given only one enemy ship remains with one unhit cell`() async throws {
        await almostSinkAllShips(on: viewModel)
    }
    
    func `When I fire at the last ship's remaining cell`() async throws {
        await viewModel.tap(Coordinate(x: 1, y: 1), boardForPlayer: .player2)
    }
    
    func `Then I see "🎉 VICTORY! You sank the enemy fleet! 🎉"`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        _ = try inspectedView.find(text: "🎉 VICTORY! You sank the enemy fleet! 🎉")
    }
    
    func `And the game ends`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        _ = try inspectedView.find(button: "New Game")
    }
    
    func `Given the game has ended`() async throws {
        await almostSinkAllShips(on: viewModel)
        await viewModel.tap(Coordinate(x: 1, y: 1), boardForPlayer: .player2)
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
                #expect(try cell.geometryReader().text().string() == "🌊")
            }
        }
    }
}
