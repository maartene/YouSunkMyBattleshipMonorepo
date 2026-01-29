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
/// I want to know when I've sunk an enemy ship
/// So that I can track my progress
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Ship Sinking Detection` {
    let viewModel: ClientViewModel
    let view: GameView
    
    init() {
        viewModel = ClientViewModel(gameService: MockGameService())
        view = GameView(viewModel: viewModel)
    }
    
    @Test func `Scenario: Player sinks enemy destroyer`() async throws {
        try await `Given the enemy has a Destroyer at I9-J9`()
        try await `And I have hit I9`()
        try await `When I fire at J9`()
        try `Then both I9 and J9 show 🔥`()
        try `And I see "You sank the enemy Destroyer!"`()
        try `And I see one less remaining ship to destroy`()
    }
}

extension `Feature: Ship Sinking Detection` {
    func `Given the enemy has a Destroyer at I9-J9`() async throws {
        addViewsToViewModel(viewModel)
        completePlacement(on: viewModel)
        await viewModel.confirmPlacement()
    }
    
    func `And I have hit I9`() async throws {
        await viewModel.tap(Coordinate("I9"), boardForPlayer: .player2)
    }
    
    func `When I fire at J9`() async throws {
        await viewModel.tap(Coordinate("J9"), boardForPlayer: .player2)
    }
    
    func `Then both I9 and J9 show 🔥`() throws {
        let trackingBoard = try getEnemyBoard(from: view)
        let rows = trackingBoard.findAll(BoardRowView.self)
        for rowIndex in [8,9] {
            let row = rows[rowIndex]
            let columns = row.findAll(CellView.self)
            
            #expect(try columns[8].geometryReader().text().string() == "🔥")
        }
    }
    
    func `And I see "You sank the enemy Destroyer!"`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        _ = try inspectedView.find(text: "You sank the enemy Destroyer!")
    }
    
    func `And I see one less remaining ship to destroy`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        _ = try inspectedView.find(text: "Remaining ships: 4")
    }
}
