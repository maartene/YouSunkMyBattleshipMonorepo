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
import YouSunkMyBattleshipCommon

/// As a player
/// I want to fire at coordinates on the enemy board 
/// So that I can try to sink their ships
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Firing Shots` {
    let viewModel: ClientViewModel
    let view: GameView
    
    init() {
        viewModel = ClientViewModel(gameService: MockGameService())
        view = GameView(viewModel: viewModel)
    }
    
    @Test func `Scenario: Player fires and misses`() async throws {
        try await `Given a game has started with all ships placed`()
        try await `When I fire at coordinate B5`()
        try `Then the tracking board shows ❌ at B5`()
        try `And I receive feedback "Miss!"`()
    }
    
    @Test func `Scenario: Player fires and hits`() async throws {
        try await `Given a game has started with all ships placed`()
        try `And one of the ship has a piece place on C5`()
        try await `When I fire at coordinate C5`()
        try `Then the tracking board shows 💥 at C5`()
        try `And I receive feedback "Hit!"`()
    }
}

// MARK: Steps
extension `Feature: Firing Shots` {
    func `Given a game has started with all ships placed`() async throws {
        addViewsToViewModel(viewModel)
        completePlacement(on: viewModel)
        await viewModel.confirmPlacement()
    }
    
    func `When I fire at coordinate B5`() async throws {
        await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: .player2)
    }
    
    func `Then the tracking board shows ❌ at B5`() throws {
        let enemyBoard = try getEnemyBoard(from: view)
        let rows = enemyBoard.findAll(BoardRowView.self)
        let row = rows[1]
        let columns = row.findAll(CellView.self)
        
        #expect(try columns[4].geometryReader().text().string() == "❌")
    }
    
    func `And I receive feedback "Miss!"`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        
        _ = try inspectedView.find(text: "Miss!")
    }
    
    private func `And one of the ship has a piece place on C5`() throws {
        
    }

    private func `When I fire at coordinate C5`() async throws {
        await viewModel.tap(Coordinate(x: 4, y: 2), boardForPlayer: .player2)
    }
    
    private func `Then the tracking board shows 💥 at C5`() throws {
        let trackingBoard = try getEnemyBoard(from: view)
        let rows = trackingBoard.findAll(BoardRowView.self)
        let row = rows[2]
        let columns = row.findAll(CellView.self)
        
        #expect(try columns[4].geometryReader().text().string() == "💥")
    }
    
    private func `And I receive feedback "Hit!"`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        
        #expect(viewModel.state == .play)
        _ = try inspectedView.find(text: "Hit!")
    }
}
