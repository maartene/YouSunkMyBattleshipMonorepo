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
final class ViewModelSpy: GameViewModel {
    let currentPlayer: Player = .player1
    
    let state: GameViewModelState
    var startDragLocation: CGPoint?
    var endDragLocation: CGPoint?
    var tapCoordinate: Coordinate?
    var tapPlayer: Player?
    private(set) var addCellWasCalled = false
    private(set) var resetWasCalled = false
    
    init(state: GameViewModelState = .placingShips) {
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
    func reset() {
        resetWasCalled = true
    }
    
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

func completePlacement(on viewModel: any GameViewModel) {
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

func almostSinkAllShips(on viewModel: GameViewModel) async {
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

// MARK: DataProvider fakes
final class DataProviderSpy: DataProvider {
    private var receivedData: [Data] = []
    private var onReceive: ((Data) -> Void)?
    
    func triggerOnReceiveWith(_ data: Data) {
        onReceive?(data)
    }
    
    func send(data: Data) async throws {
        syncSend(data: data)
    }
    
    func syncSend(data: Data) {
        let string = String(data: data, encoding: .utf8) ?? "unknown"
        print("Received string: \(string)")
        receivedData.append(data)
    }
    
    func sendWasCalledWith<T: Codable & Equatable>(_ thing: T) -> Bool {
        let decoder = JSONDecoder()
        let things = receivedData.compactMap { data -> T? in
            try? decoder.decode(type(of: thing).self, from: data)
        }
        
        return things.contains { $0 == thing }
    }
    
    func register(onReceive: @escaping (Data) -> Void) {
        self.onReceive = onReceive
    }
}

final class MockDataProvider: DataProvider {
    let dataToReceiveOnSend: Data
    private var onReceive: ((Data) -> Void)?
    
    init(dataToReceiveOnSend: Data) {
        self.dataToReceiveOnSend = dataToReceiveOnSend
    }
    
    func send(data: Data) async throws {
        onReceive?(dataToReceiveOnSend)
    }
    
    func syncSend(data: Data) {
        onReceive?(dataToReceiveOnSend)
    }
    
    func register(onReceive: @escaping (Data) -> Void) {
        self.onReceive = onReceive
    }
    
    
}
