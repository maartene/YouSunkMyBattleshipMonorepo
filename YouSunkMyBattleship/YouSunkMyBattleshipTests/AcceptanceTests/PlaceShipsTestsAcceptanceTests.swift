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
        self.viewModel = ClientViewModel(dataProvider: MockDataProvider(dataToReceiveOnSend: gameStateDataAfterCompletingPlacement))
        self.view = GameView(viewModel: viewModel)
    }

    @Test func `Scenario: Player places a ship successfully`() async throws {
        try `Given I have an empty board`()
        try await `When I tap at A1`()
        try await `And then tap at A5`()
        try `Then the cells A1 through A5 display 🚢`()
        try `And the ship placement is confirmed`()
    }

    @Test func `Scenario: Player confirms being done with placing ships`() async throws {
        try await `Given I placed all my ships`()
        try await `When I confirm placement`()
        try `Then the game shows my board is done`()
        try `And it shows the target board as well`()
        try `And it shows that there are 5 ships remaining to be destroyed`()
    }

    @Test func `Scenario: Player wants to replace ships`() async throws {
        try await `Given I placed all my ships`()
        try `When I cancel placement`()
        try `Then I get a new empty board to place ships`()
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
        #expect(try inspectedView.text().string().contains("Carrier(5)") == false)
    }

    private func `Given I placed all my ships`() async throws {
        await viewModel.tap(Coordinate("A1"), boardForPlayer: player)
        await viewModel.tap(Coordinate("A5"), boardForPlayer: player)

        await viewModel.tap(Coordinate("B2"), boardForPlayer: player)
        await viewModel.tap(Coordinate("E2"), boardForPlayer: player)

        await viewModel.tap(Coordinate("C3"), boardForPlayer: player)
        await viewModel.tap(Coordinate("C5"), boardForPlayer: player)

        await viewModel.tap(Coordinate("G8"), boardForPlayer: player)
        await viewModel.tap(Coordinate("I8"), boardForPlayer: player)

        await viewModel.tap(Coordinate("F6"), boardForPlayer: player)
        await viewModel.tap(Coordinate("F7"), boardForPlayer: player)

        #expect(viewModel.state == .awaitingConfirmation)
    }

    private func `When I confirm placement`() async throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        let button = try inspectedView.find(button: "Done!")
        try button.tap()

        while viewModel.state != .play {
            try await Task.sleep(nanoseconds: 1000)
        }
    }

    private func `Then the game shows my board is done`() throws {

        let inspectedView = try view.inspect()
        _ = try inspectedView.find(text: "Play!")
    }

    private func `And it shows the target board as well`() throws {
        let gameBoardViews = try view.inspect().findAll(GameBoardView.self)
        #expect(gameBoardViews.count == 2)
    }

    private func `And it shows that there are 5 ships remaining to be destroyed`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        _ = try inspectedView.find(text: "Remaining ships: 5")
    }

    private func `When I cancel placement`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        let button = try inspectedView.find(button: "Clear board")
        try button.tap()
    }

    private func `Then I get a new empty board to place ships`() throws {
        let rows = try getPlayerBoard(from: view)
            .find(GameBoardView.self)
            .findAll(BoardRowView.self)
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
