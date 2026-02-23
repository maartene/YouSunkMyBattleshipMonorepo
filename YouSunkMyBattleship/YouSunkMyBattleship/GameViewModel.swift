//
//  ViewModel.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 27/11/2025.
//

import SwiftUI
import CoreGraphics
import YouSunkMyBattleshipCommon

// MARK: ViewModel protocol (PORT)
protocol GameViewModel {
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) async
    func load(_ gameID: String)
    func createGame()

    var shipsToPlace: [String] { get }
    var state: GameViewModelState { get }
    var lastMessage: String { get }
    var numberOfShipsToBeDestroyed: Int { get }
    var cells: [Player: [[String]]] { get }
    var currentPlayer: Player { get }
    var opponent: Player? { get }

}

enum GameViewModelState {
    case placingShips
    case play
    case finished

    static func fromGameState(_ gameState: GameState.State) -> GameViewModelState {
        return switch gameState {
        case .placingShips:
                .placingShips
        case .play:
                .play
        case .finished:
                .finished
        }
    }
}
