//
//  ClientViewModel.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 26/01/2026.
//

import SwiftUI
import YouSunkMyBattleshipCommon

@Observable
final class ClientViewModel: ViewModel {
    private let gameService: GameService
    private let owner = Player.player1
    private(set) var shipsToPlace: [String] = []
    private(set) var state: ViewModelState = .placingShips
    private(set) var lastMessage = ""
    
    private struct PlayerCoordinate: Hashable {
        let player: Player
        let coordinate: Coordinate
    }
    
    private var cellsLocationMap: [PlayerCoordinate: CGRect] = [:]
    private var startDragPosition: Coordinate?
    private var endDragPosition: Coordinate?
    private var boardInProgress = Board()
    
    init(gameService: GameService) {
        self.gameService = gameService
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
    }
    
    func addCell(coordinate: Coordinate, rectangle: CGRect, player: Player) {
        cellsLocationMap[PlayerCoordinate(player: player, coordinate: coordinate)] = rectangle
    }
    
    func confirmPlacement() async {
        do {
            try await gameService.setBoardForPlayer(owner, board: boardInProgress)
            state = .play
            lastMessage = "Play!"
        } catch {
            print("Error submitting board: \(error)")
        }
    }
    
    func reset() {
        boardInProgress = Board()
        state = .placingShips
        updateShipsToPlace()
    }
    
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) async {
        guard boardForPlayer != owner else {
            return
        }
        
        try? await gameService.fireAt(coordinate: coordinate, against: boardForPlayer)
        
        let cell = gameService.cellsForPlayer(player: boardForPlayer)
        switch cell[coordinate.y][coordinate.x] {
        case "❌":
            lastMessage = "Miss!"
        case "💥":
            lastMessage = "Hit!"
        case "🔥":
            lastMessage = "You sank the enemy Destroyer!"
        default:
            break
        }
        
        if numberOfShipsToBeDestroyed == 0 {
            state = .finished
            lastMessage = "🎉 VICTORY! You sank the enemy fleet! 🎉"
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
    func cellsFor(_ player: Player) -> [[String]] {
        switch player {
        case .player1:
            return cellsForPlayer()
        case .player2:
            return gameService.cellsForPlayer(player: player)
        }
    }
    
    private func cellsForPlayer() -> [[String]] {
        if state == .play || state == .finished {
            return gameService.cellsForPlayer(player: .player1)
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
    
    var numberOfShipsToBeDestroyed: Int {
        gameService.numberOfShipsToBeDestroyedForPlayer(.player2)
    }
}
