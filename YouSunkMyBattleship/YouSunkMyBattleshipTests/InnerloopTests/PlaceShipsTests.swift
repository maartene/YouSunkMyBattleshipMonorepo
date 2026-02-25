//
//  PlaceShipsTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 19/12/2025.
//

import Combine
import SwiftUI
import Testing
import ViewInspector
import YouSunkMyBattleshipCommon
import WSDataProvider

@testable import YouSunkMyBattleship

@Suite(.tags(.`Unit tests`)) struct PlaceShipsTests {
    @MainActor
    @Suite struct `Interaction between View and ViewModel` {
        let viewModelSpy = ViewModelSpy()
        let view: GameView

        init() {
            self.view = GameView(viewModel: viewModelSpy, withCPU: true)
        }

        @Test func `when a cell is tapped, the viewmodel is notified`() async throws {
            let inspectedView = try view.inspect()
            let cells = inspectedView.findAll(CellView.self)
            let randomCell = try #require(cells.randomElement())

            try randomCell.text().callOnTapGesture()
            await Task.yield()
            
            #expect(viewModelSpy.tapWasCalledWithCoordinate(
                try randomCell.actualView().coordinate,
                for: try randomCell.actualView().owner))
        }
    }

    @MainActor
    @Suite struct ViewModelTests {
        let viewModel: ClientViewModel

        init() {
            viewModel = ClientViewModel(dataProvider: DummyDataProvider())
            viewModel.createGame(withCPU: true)
        }

        @Test func `when a player taps cell at A5, it becomes a ship`() async {
            await viewModel.tap(Coordinate("A5"), boardForPlayer: player)

            #expect(viewModel.cells[player]![0][4] == "🚢")
        }
        
        @Test func `given a ship placement has ended, the viewmodel sends a place ship command to the backend`() async throws {
            let dataProvider = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            viewModel.createGame(withCPU: true)
            dataProvider.triggerOnReceiveWith(gameStateDataPlacing)
            
            await viewModel.tap(Coordinate("A5"), boardForPlayer: player)            
            await viewModel.tap(Coordinate("C5"), boardForPlayer: player)
            
            let expectedCommand = GameCommand.placeShip(ship: [
                Coordinate("A5"),
                Coordinate("B5"),
                Coordinate("C5"),
            ])
            #expect(dataProvider.sendWasCalledWith(expectedCommand))
        }
    }
}
