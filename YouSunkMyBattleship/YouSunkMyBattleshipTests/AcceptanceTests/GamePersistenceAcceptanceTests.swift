//
//  GamePersistenceAcceptanceTests.swift
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
import WSDataProvider

//As a player
//I want to save my game and resume later
//So that I don't lose progress
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Game Persistence` {
    let dataProvider = MockDataProvider(dataToReceiveOnSend: gameStateDataAfterFiringHit)
    let viewModel: ClientViewModel
    let view: GameView
    
    init() {
        viewModel = ClientViewModel(dataProvider: dataProvider)
        view = GameView(viewModel: viewModel)
    }
    
    @Test func `Scenario: Player saves and resumes game`() async throws {
        try await `Given I was in an active game against CPU`()
        try await `And the game was saved as "game1"`()
        try await `And I restart and load "game1"`()
        try await `Then the board state is exactly as I left it`()
    }
}

extension `Feature: Game Persistence` {
    private func `Given I was in an active game against CPU`() async throws {
        // handled by backend
    }
    
    private func `And the game was saved as "game1"`() async throws {
        // handled by backend
    }
    
    private func `And I restart and load "game1"`() async throws {
        viewModel.load("game1")
    }
    
    private func `Then the board state is exactly as I left it`() async throws {
        let board = try getEnemyBoard(from: view)
        let rows = board.findAll(BoardRowView.self)
        let row = rows[2]
        let columns = row.findAll(CellView.self)
        let cell = columns[4]
        
        let cellContents = try cell.text().string()
        #expect(cellContents == "💥")
        
    }
}
