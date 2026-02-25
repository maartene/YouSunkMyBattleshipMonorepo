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
    private var speed: GameSpeed = .slow
    private(set) var gameID: String = "A game"
    private let owner: Player
    private let logger: Logger
    private let sessionContainer: SessionContainer

    init(repository: GameRepository, sessionContainer: SessionContainer, owner: Player? = nil, bot: Bot = RandomBot(), logger: Logger = Logger(label: "GameService")) {
        self.repository = repository
        self.sessionContainer = sessionContainer
        self.bot = bot
        self.owner = owner ?? Player(id: UUID().uuidString)
        self.logger = logger
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
        case .createGame(let withCPU, let speed):
            try await createGame(withCPU: withCPU, speed: speed)
        case .join(let gameID):
            try await joinGame(gameID)
        case .placeShip(let ship):
            try await placeShip(ship)
        case .load(let gameID):
            try await loadGame(gameID: gameID)
        case .fireAt(let coordinate):
            try await fireAt(coordinate)
        }
    }

    private func createGame(withCPU: Bool, speed: GameSpeed) async throws {
        let game = Game(player: owner, cpu: withCPU)
        self.speed = speed
        self.gameID = game.gameID
        logger.info("Created game: \(gameID) for player :\(owner.id)")
        try await saveAndSendGameState(game)
    }
    
    private func joinGame(_ gameID: String) async throws {
        guard var game = await repository.getGame(id: gameID) else {
            logger.warning("Could not find game: \(gameID)")
            throw GameServiceError.gameNotFound
        }

        game.join(owner)
        self.gameID = game.gameID
        
        await repository.setGame(game)
        
        logger.info("Player \(owner.id) joined game: \(game.gameID)")
        
        lastMessage = "\(owner.id) joined the game."
        try await saveAndSendGameState(game)
    }
    
    private func placeShip(_ coordinates: [Coordinate]) async throws {
        guard var game = await repository.getGame(id: gameID) else {
            logger.warning("Could not find game: \(gameID)")
            throw GameServiceError.gameNotFound
        }
        
        game.placeShip(coordinates, owner: owner)
        
        logger.info("Player \(owner.id) placed a ship \(coordinates) in game: \(game.gameID)")
        
        try await saveAndSendGameState(game)
    }

    private func loadGame(gameID: String) async throws {
        guard let game = await repository.getGame(id: gameID) else {
            logger.warning("Could not find game: \(gameID)")
            throw GameServiceError.gameNotFound
        }
        
        self.gameID = gameID
        
        logger.info("Player \(owner.id) loaded game: \(game.gameID)")
        
        lastMessage = "\(owner.id) joined the game."
        try await saveAndSendGameState(game)
    }

    private func fireAt(_ coordinate: Coordinate) async throws {
        guard var game = await repository.getGame(id: gameID) else {
            logger.warning("Could not find game: \(gameID)")
            throw GameServiceError.gameNotFound
        }
        
        guard let opponent = game.opponentOf(owner) else {
            logger.warning("Could not find opponent for player \(owner.id) in game: \(game.gameID)")
            throw GameServiceError.opponentNotFound
        }

        game.fireAt(coordinate, target: opponent)
        logger.info("Player \(owner.id) fired at \(coordinate) in game: \(game.gameID)")
        
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

        try await saveAndSendGameState(game)
    }

    private func processBotTurn(_ game: inout Game) async throws {
        guard game.currentPlayer == Player.cpu else {
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
        for player in game.playerBoards.keys {
            await sessionContainer.sendGameState(to: player, data)
        }
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
        logger.info("CPU fired at \(coordinate) player: \(owner.id) in game: \(game.gameID)")
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
