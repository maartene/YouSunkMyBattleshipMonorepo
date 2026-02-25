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
        @Test func `when the GameView is shown with cpu, the ViewModels 'createGame' function is called with cpu`() async throws {
            let viewModel = ViewModelSpy(state: .placingShips)
            let view = GameView(viewModel: viewModel, withCPU: true, savedGame: nil)
            let inspectedView = try view.inspect()
            
            try inspectedView.vStack().callOnAppear()
            
            #expect(viewModel.createGameWasCalled(withCPU: true))
        }
        
        @Test func `when the GameView is shown without cpu, the ViewModels 'createGame' function is called without cpu`() async throws {
            let viewModel = ViewModelSpy(state: .placingShips)
            let view = GameView(viewModel: viewModel, withCPU: false, savedGame: nil)
            let inspectedView = try view.inspect()
            
            try inspectedView.vStack().callOnAppear()
            
            #expect(viewModel.createGameWasCalled(withCPU: false))
        }
        
        @Test func `when a new game is created, the ViewModel sends a createGame command`() async throws {
            let dataProvider = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            
            viewModel.createGame(withCPU: true)
            
            let createGameCommand = GameCommand.createGame(withCPU: true, speed: .slow)
            #expect(dataProvider.sendWasCalledWith(createGameCommand))
        }
        
        @Test func `when a new game is created without a CPU, the ViewModel sends a createCommand without cpu`() async throws {
            let dataProvider = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            
            viewModel.createGame(withCPU: false)
            
            let createGameCommand = GameCommand.createGame(withCPU: false, speed: .slow)
            #expect(dataProvider.sendWasCalledWith(createGameCommand))
        }
    }
}
