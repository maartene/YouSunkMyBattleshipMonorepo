//
//  VictoryConditionTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 31/01/2026.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct VictoryConditionTests {
    @MainActor
    @Suite struct `Interaction between View and ViewModel` {
        let viewModelSpy = ViewModelSpy(state: .finished)
        let view: GameView
        
        init() {
            self.view = GameView(viewModel: viewModelSpy)
        }
        
        @Test func `when a player taps the "New game" button, the ViewModel is notified`() async throws {
            let inspectedView = try view.inspect()
            try inspectedView.find(button: "New Game").tap()
            #expect(viewModelSpy.resetWasCalled)
        }
    }
}
