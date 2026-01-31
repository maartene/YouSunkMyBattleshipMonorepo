////
////  RemoteGameServiceTests.swift
////  YouSunkMyBattleship
////
////  Created by Engels, Maarten MAK on 26/01/2026.
////
//
//import Testing
//@testable import YouSunkMyBattleship
//import YouSunkMyBattleshipCommon
//import Foundation
//import WSDataProvider
//
//@Suite struct RemoteGameServiceTests {
//    @MainActor
//    @Suite(.tags(.`Integration tests`)) struct IntegrationTests {
//        @Test func `can retrieve cells for player1 from the remote service`() {
//            let dataProvider = MockDataProvider(json: exampleJson)
//            let gameService = RemoteGameService(dataProvider: dataProvider)
//            
//            let expectedCellsForPlayer1 = [
//                ["🌊","🚢","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🚢","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","❌","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","❌","🌊","🌊"],
//                ["🌊","🌊","💥","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🔥","🔥","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"]
//            ]
//                        
//            #expect(gameService.cellsForPlayer(player: .player1) == expectedCellsForPlayer1)
//        }
//        
//        @Test func `can retrieve cells for player2 from the remote service`() {
//            let dataProvider = MockDataProvider(json: exampleJson
//            )
//            let gameService = RemoteGameService(dataProvider: dataProvider)
//            
//            let expectedCellsForPlayer2 = [
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","💥","💥","💥","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","❌","❌","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🔥","🌊","🌊","🌊","❌","🌊"],
//                ["🌊","🌊","🌊","🌊","🔥","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🔥","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"],
//                ["🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊","🌊"]
//            ]
//                        
//            #expect(gameService.cellsForPlayer(player: .player2) == expectedCellsForPlayer2)
//        }
//        
//        @Test func `when the dataprovider throws an error, an empty array of cells is returned`() {
//            let gameService = RemoteGameService(dataProvider: ThrowingDataProvider())
//            
//            #expect(gameService.cellsForPlayer(player: .player1) == [])
//        }
//        
//        @Test func `when the dataprovider returns data that cannot be converted into a GameState, an empty array of cells is returned`() {
//            let gameService = RemoteGameService(dataProvider: MockDataProvider(json: "{ cells: {} }", ))
//            
//            #expect(gameService.cellsForPlayer(player: .player1) == [])
//        }
//        
//        @Test func `when the dataprovider returns data that misses data about a player, an empty array of cells is returned`() {
//            let gameService = RemoteGameService(dataProvider: MockDataProvider(json:
//              """
//              {
//                "cells" : []
//              }
//              """))
//            
//            #expect(gameService.cellsForPlayer(player: .player2) == [])
//        }
//        
//        @Test func `can submit a valid board`() async throws {
//            let gameService = RemoteGameService(dataProvider: MockDataProvider(json: "{}"))
//            
//            try await gameService.setBoardForPlayer(.player1, board: Board.makeAnotherFilledBoard())
//        }
//        
//        @Test func `can submit a shot`() async throws {
//            let gameService = RemoteGameService(dataProvider: MockDataProvider(json: "{}"))
//            
//            try await gameService.fireAt(coordinate: Coordinate(x: 0, y: 0), against: .player2)
//        }
//        
//        @Test func `can retrieve a ship name`() async throws {
//            let gameService = RemoteGameService(dataProvider: MockDataProvider(json: "Destroyer"))
//            
//            let shipName = try await gameService.shipAt(coordinate: Coordinate("I9"))
//            #expect(shipName == "Destroyer")
//        }
//    }
//}
//
//final class MockDataProvider: DataProvider {
//    func send(data: Data) async throws {
//        
//    }
//    
//    func register(onReceive: @escaping (Data) -> Void) {
//        
//    }
//    
//    func fetch(_ endpoint: String) throws -> Data {
//        return Data(json.utf8)
//    }
//    
//    func post(_ data: Data, to endpoint: String) throws { }
//    
//    let json: String
//    
//    init(json: String) {
//        self.json = json
//    }
//}
//
//final class ThrowingDataProvider: DataProvider {
//    func send(data: Data) async throws {
//        
//    }
//    
//    func register(onReceive: @escaping (Data) -> Void) {
//        
//    }
//    
//    func fetch(_ endpoint: String) throws -> Data {
//        throw URLError(.badServerResponse)
//    }
//    
//    func post(_ data: Data, to endpoint: String) throws {
//        throw URLError(.cancelled)
//    }
//    
//    func get(_ endpoint: String, data: Data?) async throws -> Data {
//        throw URLError(.cancelled)
//    }
//}
