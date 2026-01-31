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
protocol ViewModel {
    func startDrag(at location: CGPoint)
    func endDrag(at location: CGPoint)
    func addCell(coordinate: Coordinate, rectangle: CGRect, player: Player)
    func confirmPlacement() async
    func reset()
    func tap(_ coordinate: Coordinate, boardForPlayer: Player) async
    
    var shipsToPlace: [String] { get }
    var state: ViewModelState { get }
    var lastMessage: String { get }
    var numberOfShipsToBeDestroyed: Int { get }
    var cells: [Player: [[String]]] { get }
    
}

enum ViewModelState {
    case placingShips
    case awaitingConfirmation
    case play
    case finished
    
    static func fromGameState(_ gameState: GameState.State) -> ViewModelState {
        return switch gameState {
        case .play:
            .play
        case .finished:
            .finished
        }
    }
}
