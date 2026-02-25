//
//  GamePlayer.swift
//  ContractTest
//
//  Created by Engels, Maarten MAK on 25/02/2026.
//

import Foundation
import LCLWebSocket
import YouSunkMyBattleshipCommon

final class Box<T: Sendable>: @unchecked Sendable {
    private(set) var value: T

    init(value: T) {
        self.value = value
    }

    func set(_ newValue: T) {
        self.value = newValue
    }
}

@MainActor
final class GamePlayer {
    enum PlayerState {
        case idle
        case connecting
        case connected
        case creatingGame
        case placingShips
        case playing
        case finished
    }
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let currentGameState = Box<GameState?>(value: nil)
    let config: LCLWebSocket.Configuration
    let hostname: String
    let port: String
    let player: Player
    var state: PlayerState = .idle
    var client: WebSocketClient?
    let websocket = Box<WebSocket?>(value: nil)
    let locked = Box(value: false)
    var availableMoves = Set<Coordinate>()
    let gameID: String?
    let useCPUOpponent: Bool
    
    private func setState(_ newState: PlayerState) {
        self.state = newState
    }
    
    init(playerID: String, config: LCLWebSocket.Configuration, hostname: String, port: String, gameID: String? = nil, useCPUOpponent: Bool = false) {
        self.config = config
        self.hostname = hostname
        self.port = port
        self.player = Player(id: playerID)
        var client = LCLWebSocket.client()
        self.gameID = gameID
        self.useCPUOpponent = useCPUOpponent
        
        client.onOpen { ws in
            self.websocket.set(ws)
            Task {
                await self.setState(.connected)
            }
        }

        client.onBinary { websocket, binary in
            if let state = try? self.decoder.decode(GameState.self, from: binary) {
                self.currentGameState.set(state)
                self.locked.set(false)
            }
        }

        client.onText { websocket, text in
            print("received text: \(text)")
        }

        client.onError { error in
            fatalError("Received error: \(error)")
        }
        
        self.client = client
        
        for y in 0..<Board.rows.count {
            for x in 0..<Board.columns.count {
                availableMoves.insert(Coordinate(x: x, y: y))
            }
        }
    }
    
    func act() async throws {
        switch state {
        case .idle:
            connect()
        case .connecting:
            break
        case .connected:
            try createGame()
        case .creatingGame:
            checkCreatedGame()
        case .placingShips:
            try await placeShips()
        case .playing:
            try tryPlay()
        case .finished:
            break
        }
    }
    
    func connect() {
        _ = client?.connect(to: "ws://\(hostname):\(port)/game/\(player.id)", configuration: config)
        state = .connecting
    }
    
    func createGame() throws {
        if let gameID {
            let joinGameCommand = GameCommand.join(gameID: gameID)
            try websocket.value?.send(
                joinGameCommand.toByteBuffer(using: encoder), opcode: .binary, promise: nil
            )
        } else {
            let createGameCommand = GameCommand.createGame(withCPU: useCPUOpponent, speed: .fast)
            try websocket.value?.send(
                createGameCommand.toByteBuffer(using: encoder), opcode: .binary, promise: nil)
        }
        state = .creatingGame
    }
    
    func checkCreatedGame() {
        if currentGameState.value != nil {
            state = .placingShips
        }
    }
    
    func placeShips() async throws {
        if currentGameState.value?.state == .play {
            state = .playing
            return
        }
        
        guard currentGameState.value?.state == .placingShips else {
            return
        }
        
        guard locked.value == false else {
            return
        }
        
        locked.set(true)
        
        let board = Board.makeFilledBoard()
        
        for ship in board.placedShips {
            let placeShipCommand = GameCommand.placeShip(
                ship: ship.coordinates)
            try websocket.value?.send(
                placeShipCommand.toByteBuffer(using: encoder), opcode: .binary, promise: nil)
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    func tryPlay() throws {
        guard let gameState = currentGameState.value else {
            return
        }
        
        guard gameState.state == .play else {
            print("Game finished!")
            state = .finished
            return
        }
        
        guard gameState.currentPlayer == player else {
            return
        }
        
        guard locked.value == false else {
            return
        }
        
        locked.set(true)
        
        if let move = availableMoves.randomElement() {
            availableMoves.remove(move)

            let fireCommand = GameCommand.fireAt(coordinate: move)
            try websocket.value?.send(
                fireCommand.toByteBuffer(using: encoder), opcode: .binary, promise: nil)
        } else {
            print("No more moves to make")
        }
    }
}
