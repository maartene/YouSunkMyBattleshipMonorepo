//
//  CalculateStatistics.swift
//  StatisticsBackend
//
//  Created by Maarten Engels on 09/03/2026.
//

import YouSunkMyBattleshipCommon

struct CalculateStatistics {
    func calculateStatisticsFor(_ playerID: String, in games: [Game]) throws -> PlayerStats {
        let player = games.flatMap { $0.playerBoards.keys }
            .first { $0.id == playerID }
        
        guard let player else {
            throw StatisticsBackendError.playerNotFound
        }
        
        let cpuGames = games.filter { $0.playerBoards.keys.contains(Player.cpu) }
        let cpuWins = cpuGames.count { game in
            game.hasWonGame(player) ?? false
        }
        
        return PlayerStats(cpuWins: cpuWins, totalNumberOfCPUGames: cpuGames.count, pvpWins: 0, totalNumberOfPvPGames: 0)
    }
}

enum StatisticsBackendError: Error {
    case playerNotFound
}
