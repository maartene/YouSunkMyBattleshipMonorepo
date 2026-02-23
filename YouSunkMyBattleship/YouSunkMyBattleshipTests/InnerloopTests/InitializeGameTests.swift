//
//  InitializeGameTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 23/02/2026.
//

import Testing
import YouSunkMyBattleshipCommon
import WSDataProvider
import ViewInspector

@testable import YouSunkMyBattleship

@Suite(.tags(.`Unit tests`)) struct InitializeGameTests {
    @MainActor
    @Suite struct `Creation of a new game` {
        @Test func `when the GameView is shown, the ViewModels 'createGame' function is called`() async throws {
            let viewModel = ViewModelSpy(state: .placingShips)
            let view = GameView(viewModel: viewModel, gameID: nil)
            let inspectedView = try view.inspect()
            
            try inspectedView.vStack().callOnAppear()
            
            #expect(viewModel.createGameWasCalled())
        }
        
        @Test func `when a new game is created, the ViewModel sends a createGame command`() async throws {
            let dataProvider = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            
            viewModel.createGame()
            
            let createGameCommand = GameCommand.createGameNew(withCPU: true, speed: .slow)
            #expect(dataProvider.sendWasCalledWith(createGameCommand))
        }
    }
}
