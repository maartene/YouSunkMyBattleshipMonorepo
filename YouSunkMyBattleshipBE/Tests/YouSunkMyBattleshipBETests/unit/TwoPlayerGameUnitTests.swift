//
//  TwoPlayerGameUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 24/02/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct TwoPlayerGameUnitTests {
    let repository = InmemoryGameRepository()
    let gameService1: GameService
    let gameService2: GameService
    let player1 = Player()
    let player2 = Player()
    var gameID: String!
    
    init() async throws {
        gameService1 = GameService(repository: repository, owner: player1)
        gameService2 = GameService(repository: repository, owner: player2)
    }
}
