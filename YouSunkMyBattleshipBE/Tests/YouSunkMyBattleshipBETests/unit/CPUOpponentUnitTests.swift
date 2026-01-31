//
//  CPUOpponentUnitTests.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//

import Testing
@testable import YouSunkMyBattleshipBE
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct CPUOpponentUnitTests {
    let repository = InmemoryGameRepository()
    let gameService: GameService
    
    init() async {
        gameService = GameService(repository: repository)
    }
    
    
}

// Only accept shots when its player turn
// when its CPU turn, it immediately performs actions
// CPU does not always shoot in the same place
