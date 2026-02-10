//
//  GamePersistenceAcceptanceTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/01/2026.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import Combine
import YouSunkMyBattleshipCommon
import WSDataProvider

//As a player
//I want to save my game and resume later
//So that I don't lose progress
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Game Persistence` {
    let dataProvider = DummyDataProvider()
    let view: MainMenuView
    
    init() {
        view = MainMenuView(dataProvider: dataProvider, gameViewModel: ClientViewModel(dataProvider: dataProvider))
    }
    
    @Test func `Scenario: Player saves and resumes game`() async throws {
        try await `Given I'm in an active game against CPU`()
        try await `When I save the game as "game1"`()
        try await `And I restart and load "game1"`()
        try await `Then the board state is exactly as I left it`()
    }
}

extension `Feature: Game Persistence` {
    private func `Given I'm in an active game against CPU`() async throws {
        notImplemented()
    }
    
    private func `When I save the game as "game1"`() async throws {
        notImplemented()
    }
    
    private func `And I restart and load "game1"`() async throws {
        notImplemented()
    }
    
    private func `Then the board state is exactly as I left it`() async throws {
        notImplemented()
    }
}
