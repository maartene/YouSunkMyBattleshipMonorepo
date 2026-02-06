//
//  Helpers.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 27/01/2026.
//

import Testing
import VaporTesting
import YouSunkMyBattleshipCommon
@testable import YouSunkMyBattleshipBE

func notImplemented() {
    Issue.record("Not implemented")
}

extension Tag {
    @Tag static var `E2E tests`: Self
    @Tag static var `Unit tests`: Self
    @Tag static var `Integration tests`: Self
}


func createCompletedBoard() -> Board {
    var board = Board.makeFilledBoard()
    let cellsToHit = board.placedShips.flatMap { $0.coordinates }
    
    for cell in cellsToHit {
        board.fire(at: cell)
    }
    
    return board
}
func createNearlyCompletedBoard() -> (board: Board, lastCellToHit: Coordinate) {
    var board = Board.makeFilledBoard()
    var cellsToHit = board.placedShips.flatMap { $0.coordinates }
    let lastCellToHit = cellsToHit.removeLast()
    
    for cell in cellsToHit {
        board.fire(at: cell)
    }
    
    return (board, lastCellToHit)
}

struct FixedBot: Bot {
    func getNextMoves(board: Board) async -> [Coordinate] {
        fixedMoves
    }
    
    let fixedMoves: [Coordinate]
}

func createGame(player1Board: Board, in gameService: GameService) async throws {
    let createGameCommand = GameCommand.createGame(placedShips: player1Board.placedShips.map { $0.toDTO() }, speed: .fast)
    
    try await gameService.receive(createGameCommand.toData())
}
