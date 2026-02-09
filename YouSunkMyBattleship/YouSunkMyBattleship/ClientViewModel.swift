
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
    
    private var cellsLocationMap: [PlayerCoordinate: CGRect] = [:]
    private var startDragPosition: Coordinate?
    private var endDragPosition: Coordinate?
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
    func startDrag(at location: CGPoint) {
        guard state == .placingShips else {
            return
        }
        
        guard let coordinate = cellForLocation(location) else {
            return
        }
        
        if startDragPosition == nil {
            startDragPosition = coordinate
            endDragPosition = coordinate
        } else {
            endDragPosition = coordinate
        }
        
        cells[.player1] = cellsForPlayer()
    }
    
    func endDrag(at location: CGPoint) {
        guard state == .placingShips else {
            return
        }
        
        guard let coordinate = cellForLocation(location) else {
            startDragPosition = nil
            endDragPosition = nil
            return
        }
        
        if let startDragPosition {
            let shipCoordinates = tryCreateShip(from: startDragPosition, to: coordinate)
            boardInProgress.placeShip(at: shipCoordinates)
            
            updateShipsToPlace()
        }
        
        startDragPosition = nil
        
        if boardInProgress.shipsToPlace.isEmpty {
            state = .awaitingConfirmation
        }
        
        cells[.player1] = cellsForPlayer()
    }
    
    func addCell(coordinate: Coordinate, rectangle: CGRect, player: Player) {
        print("Adding cell: \(coordinate), to \(ObjectIdentifier(self))")
        cellsLocationMap[PlayerCoordinate(player: player, coordinate: coordinate)] = rectangle
    }
    
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
        guard boardForPlayer != owner else {
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
    
    private func cellForLocation(_ location: CGPoint) -> Coordinate? {
        cellsLocationMap.filter { entry in
            entry.value.contains(location)
        }
        .first?.key.coordinate
    }
    
    private func tryCreateShip(from startCoordinate: Coordinate, to endCoordinate: Coordinate) -> [Coordinate] {
        if startCoordinate.x == endCoordinate.x || startCoordinate.y == endCoordinate.y {
            return Coordinate.makeSquare(startCoordinate, endCoordinate)
        }
        
        return []
    }
    
    private var boardBoundingBox: CGRect {
        let minX = cellsLocationMap.values.map { $0.minX }.min() ?? 0
        let minY = cellsLocationMap.values.map { $0.minY }.min() ?? 0
        let maxX = cellsLocationMap.values.map { $0.maxX }.max() ?? 0
        let maxY = cellsLocationMap.values.map { $0.maxY }.max() ?? 0
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
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
        if let startDragPosition, let endDragPosition {
            tryCreateShip(from: startDragPosition, to: endDragPosition).forEach {
                coordinate in
                cells[coordinate.y][coordinate.x] = "🚢"
            }
        }
    }
}
