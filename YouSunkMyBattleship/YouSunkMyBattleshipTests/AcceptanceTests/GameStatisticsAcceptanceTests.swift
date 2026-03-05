//
//  GameStatisticsAcceptanceTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/03/2026.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import Combine
import YouSunkMyBattleshipCommon

/// As a player 
/// I want to place my fleet on the board
/// So that I can prepare for battle
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Game Statistics` {
    @Test func `Scenario: View player statistics`() async throws {
        `Given I have completed 10 games`()
        `When I request my statistics`()
        `Then I see my total win games, wins losses`()
        `And my win rate percentage is displayed`()
    }
}

extension `Feature: Game Statistics` {
    private func `Given I have completed 10 games`() {
        notImplemented()
    }
    
    private func `When I request my statistics`() {
        notImplemented()
    }
    
    private func `Then I see my total win games, wins losses`() {
        notImplemented()
    }
    
    private func `And my win rate percentage is displayed`() {
        notImplemented()
    }
}
