//
//  Vector.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/12/2025.
//

import Foundation

public struct Coordinate {
    public let x: Int
    public let y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static let rowMap: [Int: Character] = [
        1: "A",
        2: "B",
        3: "C",
        4: "D",
        5: "E",
        6: "F",
        7: "G",
        8: "H",
        9: "I",
        10: "J"
    ]
}

extension Coordinate: Hashable {}
extension Coordinate: Sendable { }
extension Coordinate: Codable { }

extension Coordinate: CustomStringConvertible {
    public init(_ description: String) {
        var characters = description.map { String($0) }
        
        let rowCharacter = Character(characters.removeFirst())
        
        let columnString = characters.joined()
        
        guard let column = Int(columnString) else {
            fatalError("The last characters should be digits")
        }
        
        guard let row = Coordinate.rowMap.first(where: { $0.value == rowCharacter }) else {
            fatalError("The first character should be a letter A-J")
        }
        
        x = column - 1
        y = row.key - 1
    }
    
    public var description: String {
        "\(Coordinate.rowMap[y+1, default: "?"])\(x+1)"
    }
}

extension Coordinate {
    public static func makeSquare(_ c1: Coordinate, _ c2: Coordinate) -> [Coordinate] {
        var result = [Coordinate]()
        for x in min(c1.x, c2.x)...max(c1.x, c2.x) {
            for y in min(c1.y, c2.y)...max(c1.y, c2.y) {
                result.append(Coordinate(x: x, y: y))
            }
        }
        return result
    }
}
