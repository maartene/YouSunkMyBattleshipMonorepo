//
//  CalculateStatistics.swift
//  StatisticsBackend
//
//  Created by Maarten Engels on 09/03/2026.
//

import YouSunkMyBattleshipCommon

struct CalculateStatistics {
    func calculateStatisticsFor(_ player: Player, in games: [Game]) throws -> PlayerStats {
        let finishedGames = games.filter { $0.hasFinished }
        
        let cpuGames = finishedGames.filter { $0.playerBoards.keys.contains(Player.cpu) }
        let cpuWins = cpuGames.count { game in
            game.hasWonGame(player) ?? false
        }
        
        let pvpGames = finishedGames.filter { $0.opponentOf(player) != Player.cpu }
        let pvpWins = pvpGames.count { game in
            game.hasWonGame(player) ?? false
        }
        
        return PlayerStats(
            cpuWins: cpuWins,
            totalNumberOfCPUGames: cpuGames.count,
            pvpWins: pvpWins,
            totalNumberOfPvPGames: pvpGames.count)
    }
}

enum StatisticsBackendError: Error {
    case playerNotFound
}

extension Array where Element == Game {
    func getPlayer(id: String) -> Player? {
        flatMap { $0.playerBoards.keys }
        .first { $0.id == id }
    }
}
