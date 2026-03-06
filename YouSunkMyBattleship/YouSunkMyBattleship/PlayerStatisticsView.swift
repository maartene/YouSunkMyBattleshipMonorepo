//
//  PlayerStatisticsView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/03/2026.
//

import SwiftUI
import YouSunkMyBattleshipCommon
import WSDataProvider

struct PlayerStatisticsView: View {
    let stats: PlayerStats
    
    init(dataProvider: DataProvider) {
        stats = Self.getStats(dataProvider: dataProvider) ?? PlayerStats(cpuWins: 0, totalNumberOfCPUGames: 0, pvpWins: 0, totalNumberOfPvPGames: 0)
        print("received stats: \(stats)")
    }
    
    let pvpWins = 5
    let totalNumberOfPvPGames = 9
    var totalNumberOfGames: Int {
        stats.totalNumberOfCPUGames + stats.totalNumberOfPvPGames
    }
    var totalWins: Int {
        stats.cpuWins + pvpWins
    }
    var totalLosses: Int {
        totalNumberOfGames - totalWins
    }
    var cpuWinRate: Double {
        Double(stats.cpuWins) / Double(stats.totalNumberOfCPUGames)
    }
    var cpuLosses: Int {
        stats.totalNumberOfCPUGames - stats.cpuWins
    }
    
    var pvpWinRate: Double {
        Double(pvpWins) / Double(totalNumberOfPvPGames)
    }
    var averageWinRate: String {
        let winRate = Double(totalWins) / Double(totalNumberOfGames) * 100
        let winRateString = String(format: "%.0f", winRate)
        
        return "\(winRateString)%"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("📈 Player123456")
                .font(.largeTitle)
                .padding()
            Form {
                LabeledContent("# games played") {
                    Text(totalNumberOfGames.description).tag("totalGames")
                }
                LabeledContent("# games won-lost") {
                    Text("\(totalWins)-\(totalLosses)").tag("totalGamesWonLost")
                }
                LabeledContent("Average win rate") {
                    Text(averageWinRate).tag("averageWinRate")
                }
                
                Section("Win rate breakdown") {
                    LabeledContent("vs 🤖") {
                        ProgressView(value: cpuWinRate) {
                            Text("\(stats.cpuWins)-\(cpuLosses)")
                        }.tag("vsCPUWinRate")
                    }
                    
                    LabeledContent("vs 👱") {
                        ProgressView(value: pvpWinRate) {
                            Text("\(pvpWins)-4")
                        }
                    }
                }
            }
            Spacer()
        }
    }
    
    private static func getStats(dataProvider: DataProvider) -> PlayerStats? {
        do {
            guard let data = try dataProvider.syncGet(url: URL(string: "http://localhost:8081/statistics/\(player.id)")!) else {
                NSLog("Endpoint did not return any data")
                return nil
            }
            let stats = try JSONDecoder().decode(PlayerStats.self, from: data)
            return stats
        } catch {
            NSLog("Error fetching game data: \(error)")
            return nil
        }
    }
}

#Preview {
    PlayerStatisticsView(dataProvider: DummyDataProvider())
}
