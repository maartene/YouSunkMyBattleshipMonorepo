//
//  Board.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 27/11/2025.
//

public enum Cell {
    case empty
    case ship
    case hitShip
    case destroyedShip
    case miss
}

public struct Board: Sendable {
    public struct PlacedShip: Sendable, Codable {
        public let ship: Ship
        public let coordinates: [Coordinate]
    }

    public static let columns = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    public static let rows = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    public let width: Int
    public let height: Int

    private(set) var hitCells: Set<Coordinate> = []
    public private(set) var placedShips: [PlacedShip] = []

    public init() {
        width = Self.columns.count
        height = Self.rows.count
    }

    // MARK: Queries
    public var cells: [[Cell]] {
        var result = Array(
            repeating: Array(repeating: Cell.empty, count: width),
            count: height)

        let aliveShips = aliveShips

        // Mark all hit cells as miss initially
        for hitCell in hitCells {
            result[hitCell.y][hitCell.x] = .miss
        }

        for placedShip in placedShips {
            if aliveShips.contains(placedShip.ship) {
                for position in placedShip.coordinates {
                    result[position.y][position.x] = hitCells.contains(position) ? .hitShip : .ship
                }
            } else {
                for position in placedShip.coordinates {
                    result[position.y][position.x] = .destroyedShip
                }
            }
        }

        return result
    }

    public var shipsToPlace: [Ship] {
        Ship.allShips.filter {
            placedShips.map { placedShip in placedShip.ship }.contains($0) == false
        }
    }

    public var aliveShips: [Ship] {
        placedShips.filter { ship in
            ship.coordinates.allSatisfy { coordinate in
                hitCells.contains(coordinate)
            } == false
        }.map { $0.ship }
    }

    public var destroyedShips: [PlacedShip] {
        placedShips.filter { ship in
            ship.coordinates.allSatisfy { coordinate in
                hitCells.contains(coordinate)
            }
        }
    }

    // MARK: Commands
    public mutating func placeShip(at coordinates: [Coordinate]) {
        guard coordinates.count <= largestAvailableShip else {
            return
        }
        
        guard isLine(coordinates) else {
            return
        }

        guard coordinates.allSatisfy(validateShipPlacement) else {
            return
        }

        guard let shipToPlace = shipsToPlace.first(where: { $0.size == coordinates.count }) else {
            return
        }

        placedShips.append(PlacedShip(ship: shipToPlace, coordinates: coordinates))
    }
    
    private func isLine(_ coordinates: [Coordinate]) -> Bool {
        let allXAreTheSame = coordinates
            .map { $0.x }
            .allSatisfy { $0 == coordinates[0].x }
        
        let allYAreTheSame = coordinates
            .map { $0.y }
            .allSatisfy { $0 == coordinates[0].y }
        
        return allXAreTheSame || allYAreTheSame
    }

    private func validateShipPlacement(at coordinate: Coordinate) -> Bool {
        guard
            coordinate.x >= 0 && coordinate.x < width && coordinate.y >= 0 && coordinate.y < height
        else {
            return false
        }

        guard cells[coordinate.y][coordinate.x] == .empty else {
            return false
        }

        return true
    }

    private var largestAvailableShip: Int {
        shipsToPlace.map { $0.size }
            .max() ?? 0
    }

    public mutating func fire(at coordinate: Coordinate) {
        hitCells.insert(coordinate)
    }
}

extension Board: Codable {}

// MARK: Factory methods
extension Board {
    public static func makeFilledBoard() -> Board {
        var board = Board()

        // carrier
        board.placeShip(at: [
            Coordinate(x: 1, y: 1),
            Coordinate(x: 1, y: 2),
            Coordinate(x: 1, y: 3),
            Coordinate(x: 1, y: 4),
            Coordinate(x: 1, y: 5),
        ])

        // battleship
        board.placeShip(at: [
            Coordinate(x: 2, y: 2),
            Coordinate(x: 3, y: 2),
            Coordinate(x: 4, y: 2),
            Coordinate(x: 5, y: 2),
        ])

        // cruiser
        board.placeShip(at: [
            Coordinate(x: 2, y: 3),
            Coordinate(x: 3, y: 3),
            Coordinate(x: 4, y: 3),
        ])

        // submarine
        board.placeShip(at: [
            Coordinate(x: 5, y: 5),
            Coordinate(x: 5, y: 6),
            Coordinate(x: 5, y: 7),
        ])

        // destroyer
        board.placeShip(at: [
            Coordinate(x: 8, y: 8),
            Coordinate(x: 8, y: 9),
        ])

        return board
    }

    public static func makeAnotherFilledBoard() -> Board {
        var board = Board()

        // carrier
        board.placeShip(at: [
            Coordinate(x: 2, y: 1),
            Coordinate(x: 2, y: 2),
            Coordinate(x: 2, y: 3),
            Coordinate(x: 2, y: 4),
            Coordinate(x: 2, y: 5),
        ])

        // battleship
        board.placeShip(at: [
            Coordinate(x: 2, y: 0),
            Coordinate(x: 3, y: 0),
            Coordinate(x: 4, y: 0),
            Coordinate(x: 5, y: 0),
        ])

        // cruiser
        board.placeShip(at: [
            Coordinate(x: 2, y: 7),
            Coordinate(x: 3, y: 7),
            Coordinate(x: 4, y: 7),
        ])

        // submarine
        board.placeShip(at: [
            Coordinate(x: 6, y: 5),
            Coordinate(x: 6, y: 6),
            Coordinate(x: 6, y: 7),
        ])

        // destroyer
        board.placeShip(at: [
            Coordinate(x: 5, y: 8),
            Coordinate(x: 5, y: 9),
        ])

        return board
    }
}
