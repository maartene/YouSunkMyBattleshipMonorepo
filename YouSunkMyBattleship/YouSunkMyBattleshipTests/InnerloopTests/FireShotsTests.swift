//
//  FireShotsTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 30/12/2025.
//

import SwiftUI
import Testing
import ViewInspector
import YouSunkMyBattleshipCommon

@testable import YouSunkMyBattleship

@Suite(.tags(.`Unit tests`)) struct FireShotsTests {
    @MainActor
    @Suite struct `Interaction between View and ViewModel` {
        let viewModelSpy = ViewModelSpy(state: .play)
        let view: GameView

        init() {
            self.view = GameView(viewModel: viewModelSpy)
            viewModelSpy.createGame()
        }

        @Test func `when a player taps the opponents board, the viewmodel is notified`()
            async throws
        {
            let rows = try getEnemyBoard(from: view)
                .findAll(BoardRowView.self)
            let randomRow = rows.randomElement()!
            let randomCell = randomRow.findAll(CellView.self).randomElement()!

            try randomCell.text().callOnTapGesture()
            await Task.yield()

            #expect(
                viewModelSpy.tapWasCalledWithCoordinate(
                    try randomCell.actualView().coordinate, for: anOpponent))
        }

        @Test func `when a player taps their own board, the viewmodel is notified`() async throws {
            let rows = try getPlayerBoard(from: view)
                .findAll(BoardRowView.self)
            let randomRow = rows.randomElement()!
            let randomCell = randomRow.findAll(CellView.self).randomElement()!

            try randomCell.text().callOnTapGesture()
            await Task.yield()
            
            #expect(viewModelSpy.tapWasCalledWithCoordinate(
                try randomCell.actualView().coordinate, for: player))
        }
    }

    @MainActor
    @Suite struct ViewModelTests {
        @Test func `the boards for both player are independent of eachother`() async {
            let dataProvider = MockDataProvider(
                dataToReceiveOnSend: gameStateDataAfterCompletingPlacement)
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            viewModel.createGame()

            #expect(viewModel.cells[player] != viewModel.cells[anOpponent])
        }

        @Test
        func
            `when the player taps the opponents board at B5, the game service should receive a message to fire at that coordinate`()
            async throws
        {
            let spy = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: spy)
            viewModel.createGame()
            spy.triggerOnReceiveWith(gameStateDataAfterCompletingPlacement)

            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: anOpponent)

            let expectedData = GameCommand.fireAt(coordinate: Coordinate(x: 4, y: 1))

            #expect(spy.sendWasCalledWith(expectedData))
        }

        @Test
        func
            `when the player taps their own board at B5, then that should not register as an attempt`()
            async throws
        {
            let spy = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: spy)
            viewModel.createGame()

            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: player)

            let expectedData = GameCommand.fireAt(coordinate: Coordinate(x: 4, y: 1))
            #expect(spy.sendWasCalledWith(expectedData) == false)
        }

        @Test func `cannot fire shots when its not your turn`() async throws {
            let spy = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: spy)
            viewModel.createGame()

            let gameState = GameState(state: .play, currentPlayer: anOpponent)
            try spy.triggerOnReceiveWith(JSONEncoder().encode(gameState))

            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: anOpponent)

            let expectedData = GameCommand.fireAt(coordinate: Coordinate(x: 4, y: 1))
            #expect(spy.sendWasCalledWith(expectedData) == false)
        }
    }
}
