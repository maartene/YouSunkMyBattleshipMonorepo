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
    private(set) var loadWasCalled = ""
    
    init(state: GameViewModelState = .placingShips) {
        self.state = state
    }
    
    func tapWasCalledWithCoordinate(_ coordinate: Coordinate, for player: Player) -> Bool {
        tapCoordinate == coordinate && player == tapPlayer
    }
    
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) {
        tapCoordinate = coordinate
        tapPlayer = boardForPlayer
    }
    
    func loadWasCalledWithGameID(_ gameID: String) -> Bool {
        loadWasCalled == gameID
    }
    
    func load(_ gameID: String) {
        loadWasCalled = gameID
    }
    
    func confirmPlacement() {
        // no-op
    }
    
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

struct DummyGameViewModel: GameViewModel {
    func confirmPlacement() async {
        // no-op
    }
    func reset() {
        // no-op
    }
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) async {
        // no-op
    }
    func load(_ gameID: String) {
        // no-op
    }
    let shipsToPlace = [String]()
    let state: GameViewModelState = .placingShips
    let lastMessage: String = ""
    let numberOfShipsToBeDestroyed = 5
    let cells: [Player : [[String]]] = [:]
    let currentPlayer = Player.player1
}

// MARK: Helper functions
func gesture(view: some View) throws -> InspectableView<ViewType.Gesture<DragGesture>> {
    let inspectedView = try view.inspect().find(GameBoardView.self)
    return try inspectedView.grid(0).gesture(DragGesture.self)
}

func completePlacement(on viewModel: any GameViewModel) async {
    await viewModel.tap(Coordinate("A1"), boardForPlayer: .player1)
    await viewModel.tap(Coordinate("A5"), boardForPlayer: .player1)
    
    await viewModel.tap(Coordinate("B2"), boardForPlayer: .player1)
    await viewModel.tap(Coordinate("E2"), boardForPlayer: .player1)
    
    await viewModel.tap(Coordinate("C3"), boardForPlayer: .player1)
    await viewModel.tap(Coordinate("C5"), boardForPlayer: .player1)
    
    await viewModel.tap(Coordinate("G8"), boardForPlayer: .player1)
    await viewModel.tap(Coordinate("I8"), boardForPlayer: .player1)
    
    await viewModel.tap(Coordinate("F6"), boardForPlayer: .player1)
    await viewModel.tap(Coordinate("F7"), boardForPlayer: .player1)
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
    private var getCalls = [URL]()
    
    func triggerOnReceiveWith(_ data: Data) {
        onReceive?(data)
    }
    
    func wsSend(data: Data) async throws {
        wsSyncSend(data: data)
    }
    
    func wsSyncSend(data: Data) {
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
    
    func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void) {
        self.onReceive = onReceive
    }
    
    func syncGet(url: URL) throws -> Data? {
        getCalls.append(url)
        
        return nil
    }
    
    func getWasCalled(with url: URL) -> Bool {
        getCalls.contains(url)
    }
}

final class MockDataProvider: DataProvider {
    let dataToReceiveOnSend: Data
    private var onReceive: ((Data) -> Void)?
    
    init(dataToReceiveOnSend: Data) {
        self.dataToReceiveOnSend = dataToReceiveOnSend
    }
    
    func wsSend(data: Data) async throws {
        onReceive?(dataToReceiveOnSend)
    }
    
    func wsSyncSend(data: Data) {
        onReceive?(dataToReceiveOnSend)
    }
    
    func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void) {
        self.onReceive = onReceive
    }
    
    func syncGet(url: URL) throws -> Data? {
        let games = [
            "game1",
            "game2",
            "game3",
        ]
        
        return try JSONEncoder().encode(games)
    }
}

final class ThrowingDataProvider: DataProvider {
    func wsSend(data: Data) async throws {
        throw DataProviderErrors.anError
    }
    
    func wsSyncSend(data: Data) {
        
    }
    
    func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void) {
        
    }
    
    func syncGet(url: URL) throws -> Data? {
        throw DataProviderErrors.anError
    }
    
    enum DataProviderErrors: Error {
        case anError
    }
}

// MARK: MainMenuViewModel fakes
final class MainMenuViewModelSpy: MainMenuViewModel {
    let games: [SavedGame] = []
    let shouldShowRefreshMessage = true
    
    private(set) var refreshWasCalled = false
    
    func refreshGames() {
        refreshWasCalled = true
    }
}
