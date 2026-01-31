//
//  Helpers.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 30/12/2025.
//

import Foundation
import SwiftUI
import ViewInspector
@testable import YouSunkMyBattleship
import Combine
import Testing
import YouSunkMyBattleshipCommon
import WSDataProvider

func notImplemented() {
    Issue.record("Not implemented")
}

extension Tag {
    @Tag static var `E2E tests`: Self
    @Tag static var `Unit tests`: Self
    @Tag static var `Integration tests`: Self
}

// MARK: ViewModel fakes
final class ViewModelSpy: ViewModel {
    let state: ViewModelState
    var startDragLocation: CGPoint?
    var endDragLocation: CGPoint?
    var tapCoordinate: Coordinate?
    var tapPlayer: Player?
    private(set) var addCellWasCalled = false
    
    init(state: ViewModelState = .placingShips) {
        self.state = state
    }
    
    func tapWasCalledWithCoordinate(_ coordinate: Coordinate, for player: Player) -> Bool {
        tapCoordinate == coordinate && player == tapPlayer
    }
    
    func startDragWasCalled(with location: CGPoint) -> Bool {
        startDragLocation == location
    }
    
    func endDragWasCalled(with location: CGPoint) -> Bool {
        endDragLocation == location
    }
    
    func startDrag(at location: CGPoint) {
        startDragLocation = location
    }
    
    func endDrag(at location: CGPoint) {
        endDragLocation = location
    }
    
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) {
        tapCoordinate = coordinate
        tapPlayer = boardForPlayer
    }
        
    func addCell(coordinate: Coordinate, rectangle: CGRect, player: Player) {
        addCellWasCalled = true
    }
    
    func confirmPlacement() { }
    func reset() { }
    
    let cells = [
        Player.player1: [
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
        ],
        .player2: [
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
            ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊",],
        ]
    ]
    var shipsToPlace: [String] = []
    let lastMessage: String = ""
    let numberOfShipsToBeDestroyed = 0
}

// MARK: Helper functions
func gesture(view: some View) throws -> InspectableView<ViewType.Gesture<DragGesture>> {
    let inspectedView = try view.inspect().find(GameBoardView.self)
    return try inspectedView.grid(0).gesture(DragGesture.self)
}

func completePlacement(on viewModel: any ViewModel) {
    viewModel.startDrag(at: CGPoint(x: 56, y: 301))
    viewModel.endDrag(at: CGPoint(x: 185, y: 301))
    viewModel.startDrag(at: CGPoint(x: 248, y: 301))
    viewModel.endDrag(at: CGPoint(x: 248, y: 397))
    viewModel.startDrag(at: CGPoint(x: 56, y: 365))
    viewModel.endDrag(at: CGPoint(x: 120, y: 365))
    viewModel.startDrag(at: CGPoint(x: 312, y: 301))
    viewModel.endDrag(at: CGPoint(x: 312, y: 365))
    viewModel.startDrag(at: CGPoint(x: 312, y: 461))
    viewModel.endDrag(at: CGPoint(x: 344, y: 461))
}

func getPlayerBoard(from view: GameView) throws -> InspectableView<ViewType.View<GameBoardView>> {
    try view.inspect().findAll(GameBoardView.self)[0]
}

func getEnemyBoard(from view: GameView) throws -> InspectableView<ViewType.View<GameBoardView>> {
    try view.inspect().findAll(GameBoardView.self)[1]
}

func drag(from startDrag: CGPoint, to endDrag: CGPoint, in view: GameView) throws {
    let startValue = DragGesture.Value(time: Date(), location: startDrag, startLocation: startDrag, velocity: .zero)
    try gesture(from: view).callOnChanged(value: startValue)
    view.publisher.send()
    
    let endValue = DragGesture.Value(time: Date(), location: endDrag, startLocation: endDrag, velocity: .zero)
    try gesture(from: view).callOnEnded(value: endValue)
    view.publisher.send()
}

func gesture(from view: GameView) throws -> InspectableView<ViewType.Gesture<DragGesture>> {
    let inspectedView = try getPlayerBoard(from: view)
    return try inspectedView.grid(0).gesture(DragGesture.self)
}

func almostSinkAllShips(on viewModel: ViewModel) async {
    let coordinates = [
        Coordinate(x: 1, y: 2),
        Coordinate(x: 1, y: 3),
        Coordinate(x: 1, y: 4),
        Coordinate(x: 1, y: 5),
        Coordinate(x: 2, y: 2),
        Coordinate(x: 3, y: 2),
        Coordinate(x: 4, y: 2),
        Coordinate(x: 5, y: 2),
        Coordinate(x: 2, y: 3),
        Coordinate(x: 3, y: 3),
        Coordinate(x: 4, y: 3),
        Coordinate(x: 5, y: 5),
        Coordinate(x: 5, y: 6),
        Coordinate(x: 5, y: 7),
        Coordinate(x: 8, y: 8),
        Coordinate(x: 8, y: 9),
    ]
    
    for coordinate in coordinates {
        await viewModel.tap(coordinate, boardForPlayer: .player2)
    }
}

// MARK: GameService fakes
final class MockGameService: GameService {
    func cellsForPlayer(player: Player) -> [[String]] {
        var result = Array(repeating: Array(repeating: "🌊", count: 10), count: 10)
        result[1][4] = "❌"
        result[2][4] = "💥"
        result[8][8] = "🔥"
        result[9][8] = "🔥"
        return result
    }
    
    func numberOfShipsToBeDestroyedForPlayer(_ player: Player) -> Int {
        switch player {
        case .player1:
            5
        case .player2:
            4
        }
    }
    
    func shipAt(coordinate: Coordinate) async throws -> String {
        "Destroyer"
    }
}

final class FinishedGameService: GameService {
    func cellsForPlayer(player: Player) -> [[String]] {
        var result = Array(repeating: Array(repeating: "🌊", count: 10), count: 10)
        result[1][4] = "❌"
        result[2][4] = "💥"
        result[8][8] = "🔥"
        result[9][8] = "🔥"
        return result
    }
    
    func numberOfShipsToBeDestroyedForPlayer(_ player: Player) -> Int {
        switch player {
        case .player1:
            5
        case .player2:
            0
        }
    }
}

final class GameServiceSpy: GameService {
    private var firedAtCoordinate: Coordinate?
    private var firedAtPlayer: Player?
    private var setBoardCaller: Player?
    
    func cellsForPlayer(player: Player) -> [[String]] {
        Array(repeating: Array(repeating: "", count: 10), count: 10)
    }
    
    func fireAtWasCalledWith(_ coordinate: Coordinate, player: Player) -> Bool {
        firedAtCoordinate == coordinate && firedAtPlayer == player
    }
    
    func fireAt(coordinate: Coordinate, against player: Player) {
        firedAtCoordinate = coordinate
        firedAtPlayer = player
    }
    
    func fireAtWasNotCalled() -> Bool {
        firedAtPlayer == nil && firedAtCoordinate == nil
    }
    
    func setBoardWasCalledForPlayer(_ player: Player) -> Bool {
        setBoardCaller == player
    }
    
    func setBoardForPlayer(_ player: Player, board: Board) {
        setBoardCaller = player
    }
}

final class ThrowingGameService: GameService {
    enum ThrowingGameServiceError: Error {
        case aGenericError
    }
    
    func setBoardForPlayer(_ player: Player, board: Board) throws {
        throw ThrowingGameServiceError.aGenericError
    }
    
    func fireAt(coordinate: Coordinate, against player: Player) throws {
        throw ThrowingGameServiceError.aGenericError
    }
}

// MARK: DataProvider fakes
final class DummyDataProvider: DataProvider {
    func send(data: Data) async throws { }
    
    func register(onReceive: @escaping (Data) -> Void) { }
}
