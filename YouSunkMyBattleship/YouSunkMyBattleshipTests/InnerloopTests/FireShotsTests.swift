//
//  FireShotsTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 30/12/2025.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct FireShotsTests {
    @MainActor
    @Suite struct `Interaction between View and ViewModel` {
        let viewModelSpy = ViewModelSpy(state: .play)
        let view: GameView

        init() {
            self.view = GameView(viewModel: viewModelSpy)
        }
        
        @Test func `when a player taps the opponents board, the viewmodel is notified`() async throws {
            let rows = try getEnemyBoard(from: view)
                .findAll(BoardRowView.self)
            let randomRow = rows.randomElement()!
            let randomCell = randomRow.findAll(CellView.self).randomElement()!
            
            try randomCell.geometryReader().text().callOnTapGesture()
            
            while viewModelSpy.tapWasCalledWithCoordinate(try randomCell.actualView().coordinate, for: .player2) == false {
                try await Task.sleep(nanoseconds: 1000)
            }
        }
        
        @Test func `when a player taps their own board, the viewmodel is notified`() async throws {
            let rows = try getPlayerBoard(from: view)
                .findAll(BoardRowView.self)
            let randomRow = rows.randomElement()!
            let randomCell = randomRow.findAll(CellView.self).randomElement()!
            
            try randomCell.geometryReader().text().callOnTapGesture()
            
            while viewModelSpy.tapWasCalledWithCoordinate(try randomCell.actualView().coordinate, for: .player1) == false {
                try await Task.sleep(nanoseconds: 1000)
            }
        }
    }

    @MainActor
    @Suite struct ViewModelTests {
        @Test func `the boards for both player are independent of eachother`() {
            let dataProvider = MockDataProvider(dataToReceiveOnSend: gameStateDataAfterCompletingPlacement)
            let viewModel = ClientViewModel(dataProvider: dataProvider)

            completePlacement(on: viewModel)
            
            #expect(viewModel.cells[.player1] != viewModel.cells[.player2])
        }
        
        @Test func `when the player taps the opponents board at B5, the game service should receive a message to fire at that coordinate`() async throws {
            let spy = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: spy)
            
            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: .player2)
            
            let expectedData = #"{"fireAt":{"coordinate":{"x":4,"y":1}}}"#
            
            #expect(spy.sendWasCalledWith(expectedData))
        }
        
        @Test func `when the player taps their own board at B5, then that should not register as an attempt`() async throws {
            let spy = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: spy)
            
            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: .player1)
            
            let expectedData = #"{"fireAt":{"coordinate":{"x":4,"y":1}}}"#
            #expect(spy.sendWasCalledWith(expectedData) == false)
        }
        
        @Test func `cannot fire shots when its not your turn`() async throws {
            let spy = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: spy)
            let gameState = GameState(currentPlayer: .player2)
            try spy.triggerOnReceiveWith(JSONEncoder().encode(gameState))
            
            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: .player2)
            
            let expectedData = #"{"fireAt":{"coordinate":{"x":4,"y":1}}}"#
            #expect(spy.sendWasCalledWith(expectedData) == false)
        }
    }
}
