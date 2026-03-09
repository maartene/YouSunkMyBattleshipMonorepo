//
//  CalculateStatistics.swift
//  StatisticsBackend
//
//  Created by Maarten Engels on 09/03/2026.
//

import YouSunkMyBattleshipCommon

struct CalculateStatistics {
    func calculateStatistics(_ games: [Game]) -> PlayerStats {
        let cpuGames = games.filter { $0.playerBoards.keys.contains(Player.cpu) }
        
        return PlayerStats(cpuWins: 0, totalNumberOfCPUGames: cpuGames.count, pvpWins: 0, totalNumberOfPvPGames: 0)
    }
}
