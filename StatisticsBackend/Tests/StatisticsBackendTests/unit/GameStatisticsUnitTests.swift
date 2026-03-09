import Testing
import VaporTesting
import YouSunkMyBattleshipCommon

@testable import StatisticsBackend

@Suite(.tags(.`Unit tests`)) struct CalculateStatisticsUnitTests {
    let repository = MockGameRepository()
    @Test func `server health check`() async throws {
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
             try await app.testing().test(.GET, "/") { res in
                 #expect(res.status == .ok)
             }
         }
    }

    @Test func `should return the total number of played games against CPU`() async throws {
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
            try await app.testing().test(.GET, "/statistics/Player_1") { res in
                let stats = try JSONDecoder().decode(PlayerStats.self, from: res.body)
                
                #expect(res.status == .ok)
                #expect(stats.totalNumberOfCPUGames == 7)
            }
        }
    }
    
    @Test func `should return the total number of won games against CPU`() async throws {
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
            try await app.testing().test(.GET, "/statistics/Player_1") { res in
                let stats = try JSONDecoder().decode(PlayerStats.self, from: res.body)
                
                #expect(res.status == .ok)
                #expect(stats.cpuWins == 3)
            }
        }
    }

    @Test func `should return the total number of played games against other player`() async throws {
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
            try await app.testing().test(.GET, "/statistics/Player_1") { res in
                let stats = try JSONDecoder().decode(PlayerStats.self, from: res.body)
                
                #expect(res.status == .ok)
                #expect(stats.totalNumberOfPvPGames == 6)
            }
        }
    }
    
    @Test func `should return the total number of won games against other player`() async throws {
        try await withApp(configure: { app in try configure(app, repository: repository) }) { app in
            try await app.testing().test(.GET, "/statistics/Player_1") { res in
                let stats = try JSONDecoder().decode(PlayerStats.self, from: res.body)
                
                #expect(res.status == .ok)
                #expect(stats.pvpWins == 4)
            }
        }
    }
}
