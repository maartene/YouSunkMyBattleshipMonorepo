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
    let dataProvider = MockDataProvider()
    var view: PlayerStatisticsView!
    
    @Test mutating func `Scenario: View player statistics`() async throws {
        try `Given I have completed 10 games`()
        `When I request my statistics`()
        try `Then I see my total win games, wins losses`()
        try `And my win rate percentage is displayed`()
    }
}

extension `Feature: Game Statistics` {
    private func `Given I have completed 10 games`() throws {
        let stats = PlayerStats(cpuWins: 3, totalNumberOfCPUGames: 4, pvpWins: 5, totalNumberOfPvPGames: 6)
        
        dataProvider.dataToReturnOnGet = try JSONEncoder().encode(stats)
    }
    
    private mutating func `When I request my statistics`() {
        view = PlayerStatisticsView(dataProvider: dataProvider)
    }
    
    private func `Then I see my total win games, wins losses`() throws {
        let inspectedView = try view.inspect()
        let totalGamesWonLostLabel = try inspectedView.find(viewWithTag: "totalGamesWonLost")
        #expect(try totalGamesWonLostLabel.text().string() == "8-2")
        
    }
    
    private func `And my win rate percentage is displayed`() throws {
        let inspectedView = try view.inspect()
        let totalGamesWonLostLabel = try inspectedView.find(viewWithTag: "averageWinRate")
        #expect(try totalGamesWonLostLabel.text().string() == "80%")
    }
}
