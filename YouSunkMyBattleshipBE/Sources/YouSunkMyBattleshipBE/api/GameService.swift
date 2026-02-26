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
    private var lastMessage = [Player: String]()
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

    // MARK: Commands
    func receive(_ data: Data) async throws {
        let command = try decoder.decode(GameCommand.self, from: data)
        try await processCommand(command)
    }

    private func processCommand(_ command: GameCommand) async throws {
        switch command {
        case .createGame(let withCPU, let speed):
            try await createGame(withCPU: withCPU, speed: speed)
        case .join(let gameID):
            try await joinGame(gameID)
        case .load(let gameID):
            try await loadGame(gameID: gameID)
        case .placeShip(let ship):
            try await placeShip(ship)
        case .fireAt(let coordinate):
            try await fireAt(coordinate)
        }
    }

    private func createGame(withCPU: Bool, speed: GameSpeed) async throws {
        let game = Game(player: owner, cpu: withCPU)
        self.speed = speed
        self.gameID = game.gameID
        logger.info("Created game: \(gameID) for player :\(owner.id)")
        lastMessage[owner] = "Created game: \(gameID)"
        try await saveAndSendGameState(game)
    }
    
    private func joinGame(_ gameID: String) async throws {
        var game = try await getGame(gameID)

        game.join(owner)
        self.gameID = game.gameID
        
        await repository.setGame(game)
        
        logger.info("Player \(owner.id) joined game: \(game.gameID)")
        
        lastMessage[owner] = "You joined the game"
        setOpponentLastMessage("\(owner.id) joined the game.", in: game)
        try await saveAndSendGameState(game)
    }
    
    private func getGame(_ gameID: String) async throws -> Game {
        guard let game = await repository.getGame(id: gameID) else {
            logger.warning("Could not find game: \(gameID)")
            throw GameServiceError.gameNotFound
        }
        
        return game
    }
    
    private func loadGame(gameID: String) async throws {
        let game = try await getGame(gameID)
        
        self.gameID = gameID
        
        logger.info("Player \(owner.id) loaded game: \(game.gameID)")
        
        lastMessage[owner] = "Game loaded successfully"
        setOpponentLastMessage("\(owner) loaded the game successfully", in: game)
        try await saveAndSendGameState(game)
    }
    
    private func placeShip(_ coordinates: [Coordinate]) async throws {
        var game = try await getGame(gameID)
        
        game.placeShip(coordinates, owner: owner)
        
        logger.info("Player \(owner.id) placed a ship \(coordinates) in game: \(game.gameID)")

        if game.isDonePlacingShips(owner) ?? false {
            lastMessage[owner] = "Play!"
        }
        setOpponentLastMessage("Opponent placed a ship", in: game)
        
        try await saveAndSendGameState(game)
    }

    private func fireAt(_ coordinate: Coordinate) async throws {
        var game = try await getGame(gameID)
        let opponent = try getOpponent(in: game)

        game.fireAt(coordinate, target: opponent)
        logger.info("Player \(owner.id) fired at \(coordinate) in game: \(game.gameID)")
        
        guard let opponentBoard = game.playerBoards[opponent] else {
            return
        }
        
        switch opponentBoard.cells[coordinate.y][coordinate.x] {
        case .hitShip:
            lastMessage[owner] = "Hit!"
            setOpponentLastMessage("Hit!", in: game)
        case .destroyedShip:
            let destroyedShip = opponentBoard.destroyedShips.first(where: {
                $0.coordinates.contains(coordinate)
            })!
            lastMessage[owner] = "You sank the enemy \(destroyedShip.ship.name)!"
            setOpponentLastMessage("Your opponent sunk your \(destroyedShip.ship.name)", in: game)
        default:
            lastMessage[owner] = "Miss!"
            setOpponentLastMessage("Miss!", in: game)
        }

        if game.hasWonGame(owner) ?? false {
            lastMessage[owner] = "🎉 VICTORY! You sank the enemy fleet! 🎉"
            setOpponentLastMessage("💥 DEFEAT! Your opponent sank your fleet! 💥", in: game)
            try await saveAndSendGameState(game)
        } else {
            try await processBotTurn(&game)
            try await saveAndSendGameState(game)
        }
    }
    
    func getOpponent(in game: Game) throws -> Player {
        guard let opponent = game.opponentOf(owner) else {
            logger.warning("Could not find opponent for player \(owner.id) in game: \(game.gameID)")
            throw GameServiceError.opponentNotFound
        }
        return opponent
    }
    
    // MARK: GameState creation and sending
    private func saveAndSendGameState(_ game: Game) async throws {
        await self.repository.setGame(game)
        
        for player in game.playerBoards.keys {
            let data = try await getGameState(player)
            await sessionContainer.sendGameState(to: player, data)
        }
    }
    
    private func getGameState(_ player: Player) async throws -> GameState {
        guard let game = await repository.getGame(id: gameID) else {
            throw GameServiceError.gameNotFound
        }
        
        let cells = game.playerBoards.reduce(into: [Player:[[String]]]())  { result, entry in
            if entry.key == player {
                result[entry.key] = entry.value.toStringsAsPlayerBoard()
            } else {
                result[entry.key] = entry.value.toStringsAsTargetBoard()
            }
        }
        
        let shipsToPlace = game.playerBoards[player]?.shipsToPlace.map { $0.description } ?? []
        
        return GameState(
            cells: cells,
            shipsToDestroy: try game.shipsToDestroy(player: player),
            state: game.state,
            lastMessage: lastMessage[player, default: ""],
            currentPlayer: game.currentPlayer,
            shipsToPlace: shipsToPlace,
            gameID: game.gameID
        )
    }
    
    private func setOpponentLastMessage(_ message: String, in game: Game) {
        guard let opponent = game.opponentOf(owner) else {
            return
        }
        
        lastMessage[opponent] = message
    }

    // MARK: CPU performs actions
    private func processBotTurn(_ game: inout Game) async throws {
        guard game.currentPlayer == Player.cpu else {
            return
        }

        try await saveAndSendGameState(game)
        
        guard let ownerBoard = game.playerBoards[owner] else {
            return
        }
        
        let botCoordinates = await self.bot.getNextMoves(board: ownerBoard)
        lastMessage[owner] = getCPUFiresMessage(botCoordinates: botCoordinates)

        for botCoordinate in botCoordinates {
            try await cpuFire(at: botCoordinate, in: &game)
        }

        if game.hasWonGame(Player.cpu) ?? false {
            lastMessage[owner] = "💥 DEFEAT! The CPU sank your fleet! 💥"
        }

        try await saveAndSendGameState(game)
    }

    private func cpuFire(at coordinate: Coordinate, in game: inout Game) async throws {
        try await Task.sleep(nanoseconds: speed.nanoSecondDelay)
        logger.info("CPU fired at \(coordinate) player: \(owner.id) in game: \(game.gameID)")
        game.fireAt(coordinate, target: owner)
        try await saveAndSendGameState(game)
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
