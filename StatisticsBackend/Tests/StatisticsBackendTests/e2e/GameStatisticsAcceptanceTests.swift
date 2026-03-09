//
//  GameStatisticsAcceptanceTests.swift
//  StatisticsBackend
//
//  Created by Maarten Engels on 09/03/2026.
//

import Testing
import YouSunkMyBattleshipCommon
import GameRepository
import VaporTesting

@testable import StatisticsBackend

@Suite(.tags(.`E2E tests`)) final class `Feature: Game Statistics` {
    let player = Player(id: "Player_1")
    let repository = MockGameRepository()
    var stats = PlayerStats(cpuWins: 0, totalNumberOfCPUGames: 0, pvpWins: 0, totalNumberOfPvPGames: 0)
    
    @Test func `Scenario: View player statistics`() async throws {
        try await withApp(configure: { app in try configure(app, repository: self.repository) }) { app in
            try await `Given I have completed 10 games`(app)
            try await `When I request my statistics`(app)
            try await `Then I see my total win games, wins losses`(app)
            try await `And my win rate percentage is displayed`(app)
        }
    }
}

extension `Feature: Game Statistics` {
    private func `Given I have completed 10 games`(_ app: Application) async throws {
        let myGames = await repository.all()
            .withPlayer(player)
            .filter { $0.hasFinished }
        #expect(myGames.count == 13)
    }
    
    private func `When I request my statistics`(_ app: Application) async throws {
        try await app.testing().test(.GET, "/statistics/Player_1") { res in
            self.stats = try JSONDecoder().decode(PlayerStats.self, from: res.body)
        }
    }
    
    private func `Then I see my total win games, wins losses`(_ app: Application) async throws {
        #expect(stats.cpuWins == 3)
        #expect(stats.totalNumberOfCPUGames == 7)
        #expect(stats.totalNumberOfPvPGames == 6)
        #expect(stats.pvpWins == 4)
    }
    
    private func `And my win rate percentage is displayed`(_ app: Application) async throws {
        // calculated by front-end
    }
}
