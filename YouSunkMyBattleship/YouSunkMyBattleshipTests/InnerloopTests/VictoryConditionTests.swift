//
//  VictoryConditionTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 19/01/2026.
//

import Testing
@testable import YouSunkMyBattleship
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct VictoryConditionTests {
    @MainActor
    @Suite struct ViewModelTests {
        @Test func `when all ships have been hit, the game is in finished state`() async {
            let viewModel = ClientViewModel(gameService: FinishedGameService())
            addViewsToViewModel(viewModel)
            completePlacement(on: viewModel)
            await viewModel.confirmPlacement()
            
            await viewModel.tap(Coordinate(x: 1, y: 1), boardForPlayer: .player2)
            
            #expect(viewModel.state == .finished)
        }
    }
}
