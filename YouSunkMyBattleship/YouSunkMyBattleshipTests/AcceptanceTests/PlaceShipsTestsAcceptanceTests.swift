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
/// I want to place my fleet on the board
/// So that I can prepare for battle
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Ship Placement` {
    let viewModel: ClientViewModel
    let view: GameView

    init() {
        self.viewModel = ClientViewModel(dataProvider: MockDataProvider(dataToReceiveOnSend: gameStateDataAfterPlacing))
        self.view = GameView(viewModel: viewModel, withCPU: true)
        viewModel.createGame(withCPU: true)
    }

    @Test func `Scenario: Player places a ship successfully`() async throws {
        try `Given I have an empty board`()
        try await `When I tap at A1`()
        try await `And then tap at A5`()
        try `Then the cells A1 through A5 display 🚢`()
        try `And the ship placement is confirmed`()
    }
}

// MARK: Steps
extension `Feature: Ship Placement` {
    private func `Given I have an empty board`() throws {
        // no action required: default state for a new board
    }

    private func `When I tap at A1`() async throws {
        await viewModel.tap(Coordinate("A1"), boardForPlayer: player)
    }
    private func `And then tap at A5`() async throws {
        await viewModel.tap(Coordinate("A5"), boardForPlayer: player)
    }

    private func `Then the cells A1 through A5 display 🚢`() throws {
        let rows = try getPlayerBoard(from: view)

        let row = try #require(rows.first)
        let columns = row.findAll(CellView.self)

        for col in 0 ..< 5 {
            #expect(try columns[col].text().string() == "🚢")
        }
    }

    private func `And the ship placement is confirmed`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        #expect(try inspectedView.vStack().text(1).string().contains("Carrier(5)") == false)
    }
}
