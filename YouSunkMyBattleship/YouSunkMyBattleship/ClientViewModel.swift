
//
//  ClientViewModel.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 26/01/2026.
//

import SwiftUI
import YouSunkMyBattleshipCommon
import WSDataProvider

@Observable
final class ClientViewModel: GameViewModel {
    private let dataProvider: DataProvider
    private let owner = Player.player1
    private(set) var shipsToPlace: [String] = []
    private(set) var state: GameViewModelState = .placingShips
    private(set) var lastMessage = ""
    private(set) var cells: [Player : [[String]]] = [:]
    private(set) var numberOfShipsToBeDestroyed: Int = 5
    
    private struct PlayerCoordinate: Hashable {
        let player: Player
        let coordinate: Coordinate
    }
    
    private var startShip: Coordinate?
    private var endShip: Coordinate?
    private var boardInProgress = Board()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private(set) var currentPlayer = Player.player1
    
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        cells[.player1] = boardInProgress.toStringsAsPlayerBoard()
        updateShipsToPlace()
    }
    
    // MARK: Commands
    func confirmPlacement() async {
        do {
            dataProvider.connectToWebsocket(to: wsURL, onReceive: receiveData)
            let command = GameCommand.createGame(placedShips: boardInProgress.placedShips.map { $0.toDTO() }, speed: .slow )
            let data = try encoder.encode(command)
            try await dataProvider.wsSend(data: data)
        } catch {
            NSLog("Error submitting board: \(error)")
        }
    }
    
    func reset() {
        boardInProgress = Board()        
        state = .placingShips
        cells[.player1] = boardInProgress.toStringsAsPlayerBoard()
        updateShipsToPlace()
    }
    
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) async {
        switch state {
        case .placingShips:
            tapToPlaceShip(at: coordinate, player: boardForPlayer)
        case .play:
            await tapToFire(at: coordinate, player: boardForPlayer)
        default:
            break
        }
    }
    
    private func tapToPlaceShip(at coordinate: Coordinate, player: Player) {
        startShip = coordinate
        endShip = coordinate
        
        cells[.player1] = cellsForPlayer()
    }
    
    private func tapToFire(at coordinate: Coordinate, player: Player) async {
        guard player != owner else {
            return
        }
        
        guard currentPlayer == .player1 else {
            return
        }
        
        do {
            let command = GameCommand.fireAt(coordinate: coordinate)
            let data = try encoder.encode(command)
            try await dataProvider.wsSend(data: data)
        } catch {
            NSLog("Error when firing at \(coordinate): \(error)")
        }
    }
    
    private func receiveData(_ data: Data) {
        do {
            let gameState = try decoder.decode(GameState.self, from: data)
            self.cells = gameState.cells
            self.numberOfShipsToBeDestroyed = gameState.shipsToDestroy
            self.state = GameViewModelState.fromGameState(gameState.state)
            self.lastMessage = gameState.lastMessage
            self.currentPlayer = gameState.currentPlayer
        } catch {
            NSLog("Error receiving data: \(error)")
        }
    }
    
    private func tryCreateShip(from startCoordinate: Coordinate, to endCoordinate: Coordinate) -> [Coordinate] {
        if startCoordinate.x == endCoordinate.x || startCoordinate.y == endCoordinate.y {
            return Coordinate.makeSquare(startCoordinate, endCoordinate)
        }
        
        return []
    }
    
    private func updateShipsToPlace() {
        shipsToPlace = boardInProgress.shipsToPlace.map { $0.description }
    }
    
    // MARK: Queries
    
    private func cellsForPlayer() -> [[String]] {
        guard state == .placingShips else {
            return cells[.player1, default: []]
        }
        
        var result = boardInProgress.cells.map { row in
            row.map { cell in
                switch cell {
                case .empty: "🌊"
                case .ship: "🚢"
                default: " "
                }
            }
        }
        
        postProcessDraggingShip(cells: &result)
        return result
    }

    private func postProcessDraggingShip(cells: inout [[String]]) {
        if let startShip, let endShip {
            tryCreateShip(from: startShip, to: endShip).forEach {
                coordinate in
                cells[coordinate.y][coordinate.x] = "🚢"
            }
        }
    }
}
