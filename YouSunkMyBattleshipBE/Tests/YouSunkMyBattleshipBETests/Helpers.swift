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

func placeShips(in gameService: GameService) async throws {
    let placeShipCommands = [
        ["A1", "A2", "A3", "A4", "A5"],
        ["B1", "B2", "B3"],
        ["C1", "C2"],
        ["D1", "D2", "D3"],
        ["A8", "B8", "C8", "D8"]
    ].map { ship in
        ship.map { Coordinate($0) }
    }.map {
        GameCommand.placeShip(ship: $0)
    }
    
    for command in placeShipCommands {
        try await gameService.receive(command.toData())
    }
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

func getOpponent(from gameService: GameService, for player: Player) async throws -> Player {
    let gameState = try await gameService.getGameState()
    return try #require(gameState.cells.keys.first { $0 != player })
}
