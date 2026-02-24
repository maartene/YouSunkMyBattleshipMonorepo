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
    private let owner = player
    private(set) var shipsToPlace: [String] = []
    private(set) var state: GameState.State = .placingShips
    private(set) var lastMessage = ""
    private(set) var cells: [Player: [[String]]] = [:]
    private(set) var numberOfShipsToBeDestroyed: Int = 5
    private(set) var opponent: Player?

    private struct PlayerCoordinate: Hashable {
        let player: Player
        let coordinate: Coordinate
    }

    private var startShip: Coordinate?
    private var endShip: Coordinate?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private(set) var currentPlayer = player

    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }

    // MARK: Commands
    func createGame() {
        cells[owner] = Array(repeating: Array(repeating: "🌊", count: 10), count: 10)
        
        let command = GameCommand.createGame(withCPU: true, speed: .slow)
        do {
            let data = try encoder.encode(command)
            dataProvider.connectToWebsocket(to: wsURL, onReceive: receiveData)
            dataProvider.wsSyncSend(data: data)
        } catch {
            NSLog("Failed to encode command: \(command): \(error)")
        }
    }

    func load(_ gameID: String) {
        let command = GameCommand.load(gameID: gameID)
        do {
            let data = try encoder.encode(command)
            dataProvider.connectToWebsocket(to: wsURL, onReceive: receiveData)
            dataProvider.wsSyncSend(data: data)
        } catch {
            NSLog("Failed to encode command \(command): \(error)")
        }
    }
    
    func join(_ gameID: String) {
        let command = GameCommand.join(gameID: gameID)
        do {
            let data = try encoder.encode(command)
            dataProvider.connectToWebsocket(to: wsURL, onReceive: receiveData)
            dataProvider.wsSyncSend(data: data)
        } catch {
            NSLog("Failed to encode command \(command): \(error)")
        }
    }

    func tap(_ coordinate: Coordinate, boardForPlayer: Player) async {
        switch state {
        case .placingShips:
            await tapToPlaceShip(at: coordinate)
        case .play:
            await tapToFire(at: coordinate, player: boardForPlayer)
        default:
            break
        }
    }

    private func tapToPlaceShip(at coordinate: Coordinate) async {
        if let startShip {
            endShip = coordinate

            let shipCoordinates = tryCreateShip(from: startShip, to: coordinate)

            self.startShip = nil
            endShip = nil
            
            let placeShipCommand = GameCommand.placeShip(ship: shipCoordinates)
            do {
                let data = try encoder.encode(placeShipCommand)
                try await dataProvider.wsSend(data: data)
            } catch {
                NSLog("Error sending place ship command \(placeShipCommand): \(error)")
            }
        } else {
            startShip = coordinate
            endShip = coordinate
            cells[owner] = cellsForPlayer()
        }
    }

    private func tapToFire(at coordinate: Coordinate, player: Player) async {
        guard player != owner else {
            return
        }

        guard currentPlayer == owner else {
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
            self.state = gameState.state
            self.lastMessage = gameState.lastMessage
            self.currentPlayer = gameState.currentPlayer
            self.opponent = cells.keys.first(where: { $0 != owner })
            self.shipsToPlace = gameState.shipsToPlace
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

    // MARK: Queries
    private func cellsForPlayer() -> [[String]] {
        var result = cells[owner, default: []]

        if state == .placingShips {
            postProcessDraggingShip(cells: &result)
        }
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
