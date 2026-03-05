//
//  PlayerStatisticsView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/03/2026.
//

import SwiftUI
import YouSunkMyBattleshipCommon

struct PlayerStatisticsView: View {
    let stats: PlayerStats
    
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
                LabeledContent("# games won / lost") {
                    Text("\(totalWins) / \(totalLosses)")
                }
                LabeledContent("# games lost") {
                    Text(totalLosses.description)
                }
                LabeledContent("Average win rate") {
                    Text(averageWinRate)
                }
                
                Section("Win rate breakdown") {
                    LabeledContent("vs 🤖") {
                        ProgressView(value: cpuWinRate) {
                            Text("\(stats.cpuWins)/\(stats.totalNumberOfCPUGames)")
                        }.tag("vsCPUWinRate")
                    }
                    
                    LabeledContent("vs 👱") {
                        ProgressView(value: pvpWinRate) {
                            Text("\(pvpWins)/\(totalNumberOfPvPGames)")
                        }
                    }
                }
                
            }
            Spacer()
        }
    }
}

#Preview {
    PlayerStatisticsView(stats: PlayerStats(
        cpuWins: 4,
        totalNumberOfCPUGames: 6,
        pvpWins: 5,
        totalNumberOfPvPGames: 9)
    )
}
