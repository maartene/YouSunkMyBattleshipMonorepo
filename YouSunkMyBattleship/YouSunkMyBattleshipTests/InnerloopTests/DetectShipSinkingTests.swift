//
//  DetectShipSinkingTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/01/2026.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import YouSunkMyBattleshipCommon

@Suite struct DetectShipSinkingTests {
    @Suite(.tags(.`Unit tests`)) struct ViewModelTests {
        let gameService = MockGameService()
        let viewModel: ClientViewModel
        
        init() {
            self.viewModel = ClientViewModel(gameService: gameService)
        }
        
        @Test func `when all coordinates from a ship have been hit, the number of ships to destroy goes down by one`() async {
            await viewModel.tap(Coordinate("I9"), boardForPlayer: .player2)
            await viewModel.tap(Coordinate("J9"), boardForPlayer: .player2)
            
            #expect(viewModel.numberOfShipsToBeDestroyed == 4)
        }
        
        @Test func `when all coordinates from a ship have been hit again, the number of ships to destroy does not go down further`() async {
            await viewModel.tap(Coordinate("I9"), boardForPlayer: .player2)
            await viewModel.tap(Coordinate("J9"), boardForPlayer: .player2)
            await viewModel.tap(Coordinate("I9"), boardForPlayer: .player2)
            await viewModel.tap(Coordinate("J9"), boardForPlayer: .player2)
            
            #expect(viewModel.numberOfShipsToBeDestroyed == 4)
        }
    }
}
