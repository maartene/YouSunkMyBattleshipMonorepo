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
            self.view = GameView(viewModel: viewModelSpy)
        }

        @Test func `when a cell is tapped, the viewmodel is notified`() async throws {
            let inspectedView = try view.inspect()
            let cells = inspectedView.findAll(CellView.self)
            let randomCell = try #require(cells.randomElement())

            try randomCell.text().callOnTapGesture()

            while viewModelSpy.tapWasCalledWithCoordinate(
                try randomCell.actualView().coordinate,
                for: try randomCell.actualView().owner) == false {
                try await Task.sleep(nanoseconds: 1000)
            }
        }
    }

    @MainActor
    @Suite struct ViewModelTests {
        let viewModel: ClientViewModel

        init() {
            viewModel = ClientViewModel(dataProvider: DummyDataProvider())
        }

        @Test func `when a player taps cell at A5, it becomes a ship`() async {
            await viewModel.tap(Coordinate("A5"), boardForPlayer: player)

            #expect(viewModel.cells[player]![0][4] == "🚢")
        }

        @Test
        func `given a player already tapped at A5, when they tap at C5, then cells A5, B5 and C5 show 🚢`() async {
            await viewModel.tap(Coordinate("A5"), boardForPlayer: player)

            await viewModel.tap(Coordinate("C5"), boardForPlayer: player)

            #expect(viewModel.cells[player]![0][4] == "🚢")
            #expect(viewModel.cells[player]![1][4] == "🚢")
            #expect(viewModel.cells[player]![2][4] == "🚢")
        }

        @Test func `given a ship placement has ended, a new one can be started`() async {
            await viewModel.tap(Coordinate("A5"), boardForPlayer: player)
            await viewModel.tap(Coordinate("C5"), boardForPlayer: player)

            await viewModel.tap(Coordinate("F7"), boardForPlayer: player)

            #expect(viewModel.cells[player]![0][4] == "🚢")
            #expect(viewModel.cells[player]![1][4] == "🚢")
            #expect(viewModel.cells[player]![2][4] == "🚢")
            #expect(viewModel.cells[player]![5][6] == "🚢")
        }

        @Test func `when a valid ship has been placed, it is removed from the ships to place list`() async {
            await viewModel.tap(Coordinate("A5"), boardForPlayer: player)
            await viewModel.tap(Coordinate("C5"), boardForPlayer: player)

            #expect(viewModel.shipsToPlace.contains("Cruiser(3)") == false)
        }

        @Test
        func `when all ships have been placed, the viewmodel should signal to confirm placement`() async {
            await completePlacement(on: viewModel)

            #expect(viewModel.state == .awaitingConfirmation)
        }

        @Test
        func `when all ships have been placed, the viewmodel should show them all`() async {
            await viewModel.tap(Coordinate("A1"), boardForPlayer: player)
            await viewModel.tap(Coordinate("A5"), boardForPlayer: player)
            await viewModel.tap(Coordinate("A7"), boardForPlayer: player)
            await viewModel.tap(Coordinate("D7"), boardForPlayer: player)
            await viewModel.tap(Coordinate("A9"), boardForPlayer: player)
            await viewModel.tap(Coordinate("C9"), boardForPlayer: player)
            await viewModel.tap(Coordinate("C1"), boardForPlayer: player)
            await viewModel.tap(Coordinate("C3"), boardForPlayer: player)
            await viewModel.tap(Coordinate("F9"), boardForPlayer: player)
            await viewModel.tap(Coordinate("G9"), boardForPlayer: player)

            #expect(viewModel.cells[player] ==
                [
                    ["🚢", "🚢", "🚢", "🚢", "🚢", "🌊", "🚢", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊", "🚢", "🌊"],
                    ["🚢", "🚢", "🚢", "🌊", "🌊", "🌊", "🚢", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"]
                ]
            )
        }

        @Test
        func `given all ships have been placed, when the player confirms placement, the viewmodels state should move to play`()
            async throws {
            let dataProvider = MockDataProvider(dataToReceiveOnSend: gameStateDataAfterCompletingPlacementJSON)
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            await completePlacement(on: viewModel)

            await viewModel.confirmPlacement()

            #expect(viewModel.state == .play)
        }

        @Test
        func `given all ships have been placed, when the player confirms placement, the game should receive a board with the placed ships`()
            async {
            let dataProvider = MockDataProvider(dataToReceiveOnSend: gameStateDataAfterCompletingPlacementJSON)
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            await completePlacement(on: viewModel)

            await viewModel.confirmPlacement()

            #expect(viewModel.cells[player] ==
                [
                    ["🚢", "🚢", "🚢", "🚢", "🚢", "🌊", "🚢", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊", "🚢", "🌊"],
                    ["🚢", "🚢", "🚢", "🌊", "🌊", "🌊", "🚢", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🚢", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"],
                    ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊"]
                ]
            )
        }

        @Test
        func `given all ships have been placed, when the player cancels placement, the board is reset`() async {
            await completePlacement(on: viewModel)

            viewModel.reset()

            #expect(viewModel.shipsToPlace.isEmpty == false)
            #expect(viewModel.state == .placingShips)
        }

        @Test
        func `given all ships have been placed, when the player confirms placement and an error is occurred, the state does not change`()
            async throws {
            let viewModel = ClientViewModel(dataProvider: DummyDataProvider())
            await completePlacement(on: viewModel)

            await viewModel.confirmPlacement()

            #expect(viewModel.state == .awaitingConfirmation)
        }
    }

    @Suite struct GameLogicTests {
        @Test(arguments: [
            (
                [
                    Coordinate(x: 1, y: 2),
                    Coordinate(x: 1, y: 3),
                    Coordinate(x: 1, y: 4),
                    Coordinate(x: 1, y: 5),
                    Coordinate(x: 1, y: 6)
                ], Ship.carrier
            ),
            (
                [
                    Coordinate(x: 1, y: 2),
                    Coordinate(x: 2, y: 2),
                    Coordinate(x: 3, y: 2),
                    Coordinate(x: 4, y: 2),
                    Coordinate(x: 5, y: 2)
                ], Ship.carrier
            ),
            (
                [
                    Coordinate(x: 1, y: 2),
                    Coordinate(x: 2, y: 2)
                ], Ship.destroyer
            )
        ]) func `when a valid ship has been placed, it is removed from the ships to place list`(
            testcase: (coordinates: [Coordinate], expectedShip: Ship)
        ) {
            var board = Board()

            board.placeShip(at: testcase.coordinates)

            #expect(board.shipsToPlace.contains(testcase.expectedShip) == false)
        }

        @Test func `when a valid ship has been placed, inspecting its cells returns ships`() {
            var board = Board()

            let coordinates = [
                Coordinate(x: 1, y: 2),
                Coordinate(x: 1, y: 3),
                Coordinate(x: 1, y: 4),
                Coordinate(x: 1, y: 5),
                Coordinate(x: 1, y: 6)
            ]
            board.placeShip(at: coordinates)

            coordinates.forEach {
                #expect(board.cells[$0.y][$0.x] == .ship)
            }
        }

        @Test func `when a ship is placed outside of bounds, it does not get placed`() {
            var board = Board()

            let coordinates = [
                Coordinate(x: 1, y: 7),
                Coordinate(x: 1, y: 8),
                Coordinate(x: 1, y: 9),
                Coordinate(x: 1, y: 10),
                Coordinate(x: 1, y: 11)
            ]
            board.placeShip(at: coordinates)

            #expect(board.shipsToPlace.contains(.carrier))
        }

        @Test
        func `when a larger ship tries to be placed than is available, it does not get placed`() {
            var board = Board()
            let coordinates = [
                Coordinate(x: 1, y: 1),
                Coordinate(x: 2, y: 1),
                Coordinate(x: 3, y: 1),
                Coordinate(x: 4, y: 1),
                Coordinate(x: 5, y: 1)
            ]
            board.placeShip(at: coordinates)

            let otherCoordinates = [
                Coordinate(x: 1, y: 3),
                Coordinate(x: 1, y: 4),
                Coordinate(x: 1, y: 5),
                Coordinate(x: 1, y: 6),
                Coordinate(x: 1, y: 7)
            ]
            board.placeShip(at: otherCoordinates)

            #expect(board.cells[7][1] == .empty)
        }

        @Test
        func `when a ship is placed where another ship has already been placed, it does not get placed`() {
            var board = Board()
            let coordinates = [
                Coordinate(x: 1, y: 1),
                Coordinate(x: 1, y: 2),
                Coordinate(x: 1, y: 3),
                Coordinate(x: 1, y: 4),
                Coordinate(x: 1, y: 5)
            ]
            board.placeShip(at: coordinates)

            let otherCoordinates: [Coordinate] = [
                Coordinate(x: 1, y: 2),
                Coordinate(x: 2, y: 2)
            ]
            board.placeShip(at: otherCoordinates)

            let cells = board.cells

            #expect(cells[2][2] == .empty)
        }

        @Test func `when five ships have been placed, no more ships can be placed`() {
            var board = Board()
            // carrier
            board.placeShip(at: [
                Coordinate(x: 1, y: 1),
                Coordinate(x: 1, y: 2),
                Coordinate(x: 1, y: 3),
                Coordinate(x: 1, y: 4),
                Coordinate(x: 1, y: 5)
            ])

            // battleship
            board.placeShip(at: [
                Coordinate(x: 2, y: 2),
                Coordinate(x: 3, y: 2),
                Coordinate(x: 4, y: 2),
                Coordinate(x: 5, y: 2)
            ])

            // cruiser
            board.placeShip(at: [
                Coordinate(x: 2, y: 3),
                Coordinate(x: 3, y: 3),
                Coordinate(x: 4, y: 3)
            ])

            // submarine
            board.placeShip(at: [
                Coordinate(x: 5, y: 5),
                Coordinate(x: 5, y: 6),
                Coordinate(x: 5, y: 7)
            ])

            // destroyer
            board.placeShip(at: [
                Coordinate(x: 8, y: 8),
                Coordinate(x: 8, y: 9)
            ])

            #expect(board.shipsToPlace.isEmpty)
        }
    }
}
