//
//  GameService.swift
//  YouSunkMyBattleshipBE
//
//  Created by Maarten Engels on 31/01/2026.
//

import GameRepository
import Vapor
import YouSunkMyBattleshipCommon

actor GameService {
    private let repository: GameRepository
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var lastMessage = "Play!"
    private let bot: Bot
    private let ws: WebSocket?
    private var speed: GameSpeed = .slow
    private(set) var gameID: String = "A game"
    private let owner: Player

    init(repository: GameRepository, owner: Player? = nil, bot: Bot = RandomBot(), ws: WebSocket? = nil) {
        self.repository = repository
        self.bot = bot
        self.ws = ws
        self.owner = owner ?? Player(id: UUID().uuidString)
    }

    func receive(_ data: Data) async throws {
        let command = try decoder.decode(GameCommand.self, from: data)
        try await processCommand(command)
    }

    func getGameState() async throws -> GameState {
        guard let game = await repository.getGame(id: gameID) else {
            throw GameServiceError.gameNotFound
        }
        
        let cells = game.playerBoards.reduce(into: [Player:[[String]]]())  { result, entry in
            if entry.key == owner {
                result[entry.key] = entry.value.toStringsAsPlayerBoard()
            } else {
                result[entry.key] = entry.value.toStringsAsTargetBoard()
            }
        }
        
        return GameState(
            cells: cells,
            shipsToDestroy: try game.shipsToDestroy(player: owner),
            state: game.state,
            lastMessage: lastMessage,
            currentPlayer: game.currentPlayer,
            shipsToPlace: game.playerBoards[owner]?.shipsToPlace.map { $0.description } ?? []
        )
    }

    private func processCommand(_ command: GameCommand) async throws {
        switch command {
        case .createGame(let placedShips, let speed):
            try await createGame(with: placedShips, speed: speed)
        case .createGameNew:
            try await createGameNew()
        case .placeShip(let ship):
            try await placeShip(ship)
        case .load(let gameID):
            try await loadGame(gameID: gameID)
        case .fireAt(let coordinate):
            try await fireAt(coordinate)
        }
    }

    private func createGameNew() async throws {
        let game = Game(player: owner)
        self.speed = .slow
        self.gameID = game.gameID
        
        await repository.setGame(game)
    }
    
    private func placeShip(_ coordinates: [Coordinate]) async throws {
        guard var game = await repository.getGame(id: gameID) else {
            throw GameServiceError.gameNotFound
        }
        
        game.placeShip(coordinates, owner: owner)
        
        await repository.setGame(game)
    }
    
    private func createGame(with placedShips: [PlacedShipDTO], speed: GameSpeed) async throws {
        var board = Board()
        for ship in placedShips {
            board.placeShip(at: ship.coordinates)
        }

        guard board.placedShips.count == 5 else {
            throw GameServiceError.invalidBoard
        }

        let game = Game(player1Board: board, player2Board: .makeAnotherFilledBoard(), player1: owner)

        self.speed = speed
        self.gameID = game.gameID

        await repository.setGame(game)
    }

    private func loadGame(gameID: String) async throws {
        self.gameID = gameID
    }

    private func fireAt(_ coordinate: Coordinate) async throws {
        guard var game = await repository.getGame(id: gameID) else {
            throw GameServiceError.gameNotFound
        }
        
        guard let opponent = game.opponentOf(owner) else {
            throw GameServiceError.opponentNotFound
        }

        game.fireAt(coordinate, target: opponent)

        guard let opponentBoard = game.playerBoards[opponent] else {
            return
        }
        
        switch opponentBoard.cells[coordinate.y][coordinate.x] {
        case .hitShip: lastMessage = "Hit!"
        case .destroyedShip:
            let destroyedShip = opponentBoard.destroyedShips.first(where: {
                $0.coordinates.contains(coordinate)
            })!
            lastMessage = "You sank the enemy \(destroyedShip.ship.name)!"
        default: lastMessage = "Miss!"
        }

        if opponentBoard.aliveShips.isEmpty == false {
            try await processBotTurn(&game)
        } else {
            lastMessage = "🎉 VICTORY! You sank the enemy fleet! 🎉"
        }

        await repository.setGame(game)
    }

    private func processBotTurn(_ game: inout Game) async throws {
        guard game.currentPlayer == game.opponentOf(owner) else {
            return
        }

        try await saveAndSendGameState(game)
        
        guard let ownerBoard = game.playerBoards[owner] else {
            return
        }
        
        let botCoordinates = await self.bot.getNextMoves(board: ownerBoard)
        lastMessage = getCPUFiresMessage(botCoordinates: botCoordinates)

        for botCoordinate in botCoordinates {
            try await cpuFire(at: botCoordinate, in: &game)
        }

        if game.playerBoards[owner]?.aliveShips.isEmpty ?? false {
            lastMessage = "💥 DEFEAT! The CPU sank your fleet! 💥"
        }

        await self.repository.setGame(game)
    }

    private func saveAndSendGameState(_ game: Game) async throws {
        await self.repository.setGame(game)
        let data = try await getGameState()
        try ws?.send(encoder.encode(data))
    }

    private func getCPUFiresMessage(botCoordinates: [Coordinate]) -> String {
        return switch botCoordinates.count {
        case 1: "CPU fires at \(botCoordinates[0])"
        case 2: "CPU fires at \(botCoordinates[0]) and \(botCoordinates[1])"
        case 3:
            "CPU fires at \(botCoordinates[0]), \(botCoordinates[1]) and \(botCoordinates[2])"
        default: ""
        }
    }

    private func cpuFire(at coordinate: Coordinate, in game: inout Game) async throws {
        try await Task.sleep(nanoseconds: speed.nanoSecondDelay)
        game.fireAt(coordinate, target: owner)
        try await saveAndSendGameState(game)
    }
}

enum GameServiceError: Error {
    case invalidBoard
    case boardNotFound
    case gameNotFound
    case opponentNotFound
}

extension Game {
    func shipsToDestroy(player: Player) throws -> Int {
        guard let opponent = opponentOf(player) else {
            return 5
        }
        
        guard let board = playerBoards[opponent] else {
            throw GameServiceError.boardNotFound
        }
        
        return board.aliveShips.count
    }

    var state: GameState.State {
        let incompleteBoards = playerBoards
            .map { $0.value }
            .contains { board in
                board.shipsToPlace.isEmpty == false
            }
        
        if incompleteBoards {
            return .placingShips
        }
        
        return playerBoards.contains { $0.value.aliveShips.isEmpty } ? .finished : .play
    }
}

extension GameSpeed {
    var nanoSecondDelay: UInt64 {
        let delay = self == .fast ? 0.1 : 0.75
        return UInt64(1_000_000_000.0 * delay)
    }
}
