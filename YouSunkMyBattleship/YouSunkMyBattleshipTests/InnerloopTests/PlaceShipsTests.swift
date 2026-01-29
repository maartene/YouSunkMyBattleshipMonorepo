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

@testable import YouSunkMyBattleship

@Suite(.tags(.`Unit tests`)) struct PlaceShipsTests {
    @MainActor
    @Suite struct `Interaction between View and ViewModel` {
        let viewModelSpy = ViewModelSpy()
        let view: GameView

        init() {
            self.view = GameView(viewModel: viewModelSpy)
        }

        @Test func `when a drag starts, the viewmodel is notified`() throws {
            // Send gesture
            let value = DragGesture.Value(
                time: Date(), location: CGPoint(x: 70, y: 300),
                startLocation: CGPoint(x: 70, y: 300), velocity: .zero)
            try gesture(view: view).callOnChanged(value: value)
            view.publisher.send()

            #expect(viewModelSpy.startDragWasCalled(with: CGPoint(x: 70, y: 300)))
        }

        @Test func `when a drag ends, the viewmodel is notified`() throws {
            let value = DragGesture.Value(
                time: Date(), location: CGPoint(x: 200, y: 300),
                startLocation: CGPoint(x: 200, y: 300), velocity: .zero)
            try gesture(view: view).callOnEnded(value: value)
            view.publisher.send()

            #expect(viewModelSpy.endDragWasCalled(with: CGPoint(x: 200, y: 300)))
        }

        @Test func `only the player board is draggable`() throws {
            let viewModelSpy = ViewModelSpy(state: .play)
            let view = GameView(viewModel: viewModelSpy)
            
            let playerBoard = try getPlayerBoard(from: view)
            let opponentBoard = try getEnemyBoard(from: view)

            #expect(try playerBoard.actualView().isDraggable == true)
            #expect(try opponentBoard.actualView().isDraggable == false)
        }

        @Test func `the player board triggers adding views to viewmodel`() throws {
            let viewModelSpy = ViewModelSpy(state: .play)
            let view = GameView(viewModel: viewModelSpy)
            
            let playerBoard = try getPlayerBoard(from: view)

            let cells = playerBoard.findAll(CellView.self)

            try cells.randomElement()!
                .geometryReader()
                .text()
                .callOnAppear()
            
            #expect(viewModelSpy.addCellWasCalled)
        }
        
        @Test func `the target board does not trigger adding views to viewmodel`() throws {
            let viewModelSpy = ViewModelSpy(state: .play)
            let view = GameView(viewModel: viewModelSpy)
            
            let enemyBoard = try getEnemyBoard(from: view)

            let cells = enemyBoard.findAll(CellView.self)

            try cells.randomElement()!
                .geometryReader()
                .text()
                .callOnAppear()
            
            #expect(viewModelSpy.addCellWasCalled == false)
        }
    }

    @MainActor
    @Suite struct ViewModelTests {
        let viewModel: ClientViewModel

        init() {
            viewModel = ClientViewModel(gameService: DummyGameService())
            addViewsToViewModel(viewModel)
        }

        @Test func `when a drag starts at 195,301 then the cell at A5 becomes a ship`() {
            viewModel.startDrag(at: CGPoint(x: 195, y: 301))

            #expect(viewModel.cells[.player1]![0][4] == "🚢")
        }

        @Test
        func
            `given a drag already started, when a drag moves to  195,370 then the cells A5, B5 and C5 becomes a ship`()
        {
            viewModel.startDrag(at: CGPoint(x: 195, y: 301))

            viewModel.startDrag(at: CGPoint(x: 195, y: 370))

            #expect(viewModel.cells[.player1]![0][4] == "🚢")
            #expect(viewModel.cells[.player1]![1][4] == "🚢")
            #expect(viewModel.cells[.player1]![2][4] == "🚢")
        }

        @Test
        func
            `given a drag already started, when a end at 195,370 then the cells A5, B5 and C5 becomes a ship`()
        {
            viewModel.startDrag(at: CGPoint(x: 195, y: 301))

            viewModel.endDrag(at: CGPoint(x: 195, y: 370))

            #expect(viewModel.cells[.player1]![0][4] == "🚢")
            #expect(viewModel.cells[.player1]![1][4] == "🚢")
            #expect(viewModel.cells[.player1]![2][4] == "🚢")
        }

        @Test
        func
            `given a drag already started, when a drag is outside of an ocean tile, the cells remain ships`()
        {
            viewModel.startDrag(at: CGPoint(x: 195, y: 301))
            viewModel.startDrag(at: CGPoint(x: 195, y: 370))

            viewModel.startDrag(at: CGPoint(x: 195, y: 389))

            #expect(viewModel.cells[.player1]![0][4] == "🚢")
            #expect(viewModel.cells[.player1]![1][4] == "🚢")
            #expect(viewModel.cells[.player1]![2][4] == "🚢")
        }

        @Test
        func
            `given a drag already started, when a drag ends outside of the board, the drag is reset`()
        {
            viewModel.startDrag(at: CGPoint(x: 195, y: 370))
            viewModel.endDrag(at: CGPoint(x: 0, y: 0))

            viewModel.startDrag(at: CGPoint(x: 312, y: 461))
            viewModel.endDrag(at: CGPoint(x: 344, y: 461))

            #expect(viewModel.cells[.player1]![5][8] == "🚢")
            #expect(viewModel.cells[.player1]![5][9] == "🚢")
        }

        @Test func `given a drag has ended, a new drag can be started`() {
            viewModel.startDrag(at: CGPoint(x: 195, y: 301))
            viewModel.endDrag(at: CGPoint(x: 195, y: 370))

            viewModel.startDrag(at: CGPoint(x: 248, y: 461))

            #expect(viewModel.cells[.player1]![0][4] == "🚢")
            #expect(viewModel.cells[.player1]![1][4] == "🚢")
            #expect(viewModel.cells[.player1]![2][4] == "🚢")
            #expect(viewModel.cells[.player1]![5][6] == "🚢")
        }

        @Test func `when a valid ship has been placed, it is removed from the ships to place list`()
        {
            viewModel.startDrag(at: CGPoint(x: 195, y: 301))
            viewModel.endDrag(at: CGPoint(x: 195, y: 370))

            #expect(viewModel.shipsToPlace.contains("Cruiser(3)") == false)
        }

        @Test
        func `when all ships have been placed, the viewmodel should signal to confirm placement`() {
            completePlacement(on: viewModel)

            #expect(viewModel.state == .awaitingConfirmation)
        }

        @Test
        func
            `given all ships have been placed, when the player confirms placement, the viewmodels state should move to play`()
            async
        {
            completePlacement(on: viewModel)

            await viewModel.confirmPlacement()

            #expect(viewModel.state == .play)
        }

        @Test
        func
            `given all ships have been placed, when the player confirms placement, the game services setBoard should be called`()
            async
        {
            let spy = GameServiceSpy()
            let viewModel = ClientViewModel(gameService: spy)
            completePlacement(on: viewModel)

            await viewModel.confirmPlacement()

            #expect(spy.setBoardWasCalledForPlayer(.player1))
        }

        @Test
        func
            `given all ships have been placed, when the player cancels placement, the board is reset`()
        {
            completePlacement(on: viewModel)

            viewModel.reset()

            #expect(viewModel.shipsToPlace.isEmpty == false)
            #expect(viewModel.state == .placingShips)
        }

        @Test
        func
            `given all ships have been placed, when the player confirms placement and an error is occurred, the state does not change`()
            async throws
        {
            let viewModel = ClientViewModel(gameService: ThrowingGameService())
            addViewsToViewModel(viewModel)
            completePlacement(on: viewModel)

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
                    Coordinate(x: 1, y: 6),
                ], Ship.carrier
            ),
            (
                [
                    Coordinate(x: 1, y: 2),
                    Coordinate(x: 2, y: 2),
                    Coordinate(x: 3, y: 2),
                    Coordinate(x: 4, y: 2),
                    Coordinate(x: 5, y: 2),
                ], Ship.carrier
            ),
            (
                [
                    Coordinate(x: 1, y: 2),
                    Coordinate(x: 2, y: 2),
                ], Ship.destroyer
            ),
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
                Coordinate(x: 1, y: 6),
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
                Coordinate(x: 1, y: 11),
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
                Coordinate(x: 5, y: 1),
            ]
            board.placeShip(at: coordinates)

            let otherCoordinates = [
                Coordinate(x: 1, y: 3),
                Coordinate(x: 1, y: 4),
                Coordinate(x: 1, y: 5),
                Coordinate(x: 1, y: 6),
                Coordinate(x: 1, y: 7),
            ]
            board.placeShip(at: otherCoordinates)

            #expect(board.cells[7][1] == .empty)
        }

        @Test
        func
            `when a ship is placed where another ship has already been placed, it does not get placed`()
        {
            var board = Board()
            let coordinates = [
                Coordinate(x: 1, y: 1),
                Coordinate(x: 1, y: 2),
                Coordinate(x: 1, y: 3),
                Coordinate(x: 1, y: 4),
                Coordinate(x: 1, y: 5),
            ]
            board.placeShip(at: coordinates)

            let otherCoordinates: [Coordinate] = [
                Coordinate(x: 1, y: 2),
                Coordinate(x: 2, y: 2),
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
                Coordinate(x: 1, y: 5),
            ])

            // battleship
            board.placeShip(at: [
                Coordinate(x: 2, y: 2),
                Coordinate(x: 3, y: 2),
                Coordinate(x: 4, y: 2),
                Coordinate(x: 5, y: 2),
            ])

            // cruiser
            board.placeShip(at: [
                Coordinate(x: 2, y: 3),
                Coordinate(x: 3, y: 3),
                Coordinate(x: 4, y: 3),
            ])

            // submarine
            board.placeShip(at: [
                Coordinate(x: 5, y: 5),
                Coordinate(x: 5, y: 6),
                Coordinate(x: 5, y: 7),
            ])

            // destroyer
            board.placeShip(at: [
                Coordinate(x: 8, y: 8),
                Coordinate(x: 8, y: 9),
            ])

            #expect(board.shipsToPlace.isEmpty)
        }
    }
}
