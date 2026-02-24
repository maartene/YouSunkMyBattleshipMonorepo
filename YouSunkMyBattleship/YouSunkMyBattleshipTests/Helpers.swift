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

let anOpponent = Player()

// MARK: ViewModel fakes
final class ViewModelSpy: GameViewModel {
    let opponent: Player? = anOpponent
    
    let currentPlayer: Player = player

    let state: GameState.State
    var startDragLocation: CGPoint?
    var endDragLocation: CGPoint?
    var tapCoordinate: Coordinate?
    var tapPlayer: Player?
    private(set) var loadWasCalled = ""
    private(set) var joinWasCalled = ""
    private(set) var createGameCalled = false

    init(state: GameState.State = .placingShips) {
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
    
    func joinWasCalledWithGameID(_ gameID: String) -> Bool {
        joinWasCalled == gameID
    }

    func join(_ gameID: String) {
        joinWasCalled = gameID
    }
    
    func createGameWasCalled() -> Bool {
        createGameCalled
    }
    
    func createGame() {
        createGameCalled = true
    }

    let cells = [
        player: [
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ]
        ],
        anOpponent: [
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ],
            ["🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" ]
        ]
    ]
    var shipsToPlace: [String] = []
    let lastMessage: String = ""
    let numberOfShipsToBeDestroyed = 0
}

struct DummyGameViewModel: GameViewModel {
    let opponent: Player? = nil
    
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) async {
        // no-op
    }
    func load(_ gameID: String) {
        // no-op
    }
    func join(_ gameID: String) {
        // no-op
    }
    func createGame() {
        // no-op
    }
    let shipsToPlace = [String]()
    let state: GameState.State = .placingShips
    let lastMessage: String = ""
    let numberOfShipsToBeDestroyed = 5
    let cells: [Player: [[String]]] = [:]
    let currentPlayer = player
}

// MARK: Helper functions
func completePlacement(on viewModel: any GameViewModel) async {
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
}

func getPlayerBoard(from view: GameView) throws -> InspectableView<ViewType.View<GameBoardView>> {
    try view.inspect().findAll(GameBoardView.self)[0]
}

func getEnemyBoard(from view: GameView) throws -> InspectableView<ViewType.View<GameBoardView>> {
    try view.inspect().findAll(GameBoardView.self)[1]
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
    
    func triggerOnReceiveWith(_ data: Data) {
        self.onReceive?(data)
    }

    func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void) {
        self.onReceive = onReceive
    }

    func syncGet(url: URL) throws -> Data? {
        var game3 = Game(gameID: "game3", player: player, cpu: false)
        game3.join(Player())
        var game4 = Game(gameID: "game4", player: Player(), cpu: false)
        game4.join(Player())
        
        let savedGames = [
            Game(gameID: "game1", player: player, cpu: true),
            Game(gameID: "game2", player: Player(), cpu: false),
            game3,
            game4
        ].map { SavedGame(from: $0) }

        return try JSONEncoder().encode(savedGames)
    }
}

final class ThrowingDataProvider: DataProvider {
    func wsSend(data: Data) async throws {
        throw DataProviderErrors.anError
    }

    func wsSyncSend(data: Data) {
        // no-op
    }

    func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void) {
        // no-op
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

final class MockMainMenuViewModel: MainMenuViewModel {
    let games: [SavedGame]
    
    init() {
        let otherPlayer = Player()
        let joinableGame = Game(gameID: "joinableGame", player: Player())
        var continueableGame = Game(gameID: "continueableGame", player: Player())
        continueableGame.join(player)
        var neitherGame = Game(gameID: "neither", player: Player())
        neitherGame.join(Player())
        games = [joinableGame, continueableGame, neitherGame].map { SavedGame(from: $0) }
    }
    
    let shouldShowRefreshMessage = false
    
    func refreshGames() {
        
    }
    
    
}
