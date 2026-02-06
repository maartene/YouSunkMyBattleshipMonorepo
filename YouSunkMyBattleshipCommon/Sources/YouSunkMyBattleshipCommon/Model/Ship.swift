//
//  Ship.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/01/2026.
//

public struct Ship: Sendable {
    public let name: String
    public let size: Int
}

extension Ship: CustomStringConvertible {
    public var description: String {
        "\(name)(\(size))"
    }
}

extension Ship: Equatable, Hashable { }
extension Ship: Codable { }

extension Ship {
    public static var carrier: Ship {
        Ship(name: "Carrier", size: 5)
    }
    
    public static var destroyer: Ship {
        Ship(name: "Destroyer", size: 2)
    }
    
    public static var submarine: Ship {
        Ship(name: "Submarine", size: 3)
    }
    
    public static var cruiser: Ship {
        Ship(name: "Cruiser", size: 3)
    }
    
    public static var battleship: Ship {
        Ship(name: "Battleship", size: 4)
    }
    
    public static var allShips: [Ship] {
        [
            .carrier,
            .battleship,
            .cruiser,
            .submarine,
            .destroyer
        ]
    }
}
