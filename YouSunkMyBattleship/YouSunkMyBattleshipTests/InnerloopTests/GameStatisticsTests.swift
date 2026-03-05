//
//  GameStatisticsTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/03/2026.
//

import Testing
import YouSunkMyBattleshipCommon
import WSDataProvider
import ViewInspector

@testable import YouSunkMyBattleship


@Suite(.tags(.`Unit tests`)) struct GameStatisticsTests {
    @MainActor
    @Suite struct `View should show correct values` {
        let playerStatistics = PlayerStats(cpuWins: 4, totalNumberOfCPUGames: 5, pvpWins: 3, totalNumberOfPvPGames: 7)
        let view: PlayerStatisticsView
        
        init() {
            self.view = PlayerStatisticsView(stats: playerStatistics)
        }
        
        @Test func `total number of games played should be 12`() throws {
            let inspectedView = try view.inspect()
            let totalGamesView = try inspectedView.find(viewWithTag: "totalGames")
            let totalNumberOfGames = try totalGamesView.text().string()
            #expect(totalNumberOfGames == "12")
        }
    }
    
}
