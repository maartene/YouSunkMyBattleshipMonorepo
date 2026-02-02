////
////  GameService.swift
////  YouSunkMyBattleship
////
////  Created by Engels, Maarten MAK on 26/01/2026.
////
//
//import YouSunkMyBattleshipCommon
//import Foundation
//import WSDataProvider
//
//protocol GameService {
//    func numberOfShipsToBeDestroyedForPlayer(_ player: Player) -> Int
//    func cellsForPlayer(player: Player) -> [[String]]
//    func fireAt(coordinate: Coordinate, against player: Player) async throws
//    func setBoardForPlayer(_ player: Player, board: Board) async throws
//    func shipAt(coordinate: Coordinate) async throws -> String
//}
//
//extension GameService {
//    func numberOfShipsToBeDestroyedForPlayer(_ player: Player) -> Int {
//        5
//    }
//    
//    func cellsForPlayer(player: Player) -> [[String]] {
//        Array(repeating: Array(repeating: "", count: 10), count: 10)
//    }
//    
//    func fireAt(coordinate: Coordinate, against player: Player) async throws {
//        print("WARNING: calling dummy implementation of fireAt")
//    }
//    
//    func setBoardForPlayer(_ player: Player, board: Board) async throws {
//        print("WARNING: calling dummy implementation of setBoardForPlayer")
//    }
//    
//    func shipAt(coordinate: Coordinate) async throws -> String {
//        ""
//    }
//}
//
//final class DummyGameService: GameService {
//    
//}
//
//
//// MARK: RemoteGameService
//final class RemoteGameService: GameService {
//    private let dataProvider: DataProvider
//    private let decoder = JSONDecoder()
//    private let encoder = JSONEncoder()
//    
//    init(dataProvider: DataProvider) {
//        self.dataProvider = dataProvider
//    }
//    
//    func cellsForPlayer(player: Player) -> [[String]] {
//            return []
//    }
//    
//    func numberOfShipsToBeDestroyedForPlayer(_ player: Player) -> Int {
//        5
//    }
//    
//    func setBoardForPlayer(_ player: Player, board: Board) async throws {
//    }
//    
//    func fireAt(coordinate: Coordinate, against player: Player) async throws {
//    }
//    
//    func shipAt(coordinate: Coordinate) async throws -> String {
//        "Destroyer"
//    }
//}
