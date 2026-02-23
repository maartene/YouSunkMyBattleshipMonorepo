//
//  InitializeGameTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 23/02/2026.
//

import Testing
import YouSunkMyBattleshipCommon
import WSDataProvider

@testable import YouSunkMyBattleship

@Suite(.tags(.`Unit tests`)) struct InitializeGameTests {
    @MainActor
    @Suite struct `Creation of a new game` {
        @Test func `when a new game is created, the ViewModel sends a createGame command`() async throws {
            let dataProvider = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: dataProvider)
            
            viewModel.createGame()
            
            let createGameCommand = GameCommand.createGameNew(withCPU: true, speed: .slow)
            #expect(dataProvider.sendWasCalledWith(createGameCommand))
        }
    }
}
