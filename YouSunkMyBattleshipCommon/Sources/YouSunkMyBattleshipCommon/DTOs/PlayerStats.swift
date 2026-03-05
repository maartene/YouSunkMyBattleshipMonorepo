//
//  PlayerStats.swift
//  YouSunkMyBattleshipCommon
//
//  Created by Maarten Engels on 05/03/2026.
//

public struct PlayerStats: Codable {
    public let cpuWins: Int
    public let totalNumberOfCPUGames: Int
    public let pvpWins: Int
    public let totalNumberOfPvPGames: Int
    
    public init(cpuWins: Int, totalNumberOfCPUGames: Int, pvpWins: Int, totalNumberOfPvPGames: Int) {
        self.cpuWins = cpuWins
        self.totalNumberOfCPUGames = totalNumberOfCPUGames
        self.pvpWins = pvpWins
        self.totalNumberOfPvPGames = totalNumberOfPvPGames
    }
}
