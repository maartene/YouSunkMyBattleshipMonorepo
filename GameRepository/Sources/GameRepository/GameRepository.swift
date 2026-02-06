// The Swift Programming Language
// https://docs.swift.org/swift-book

import YouSunkMyBattleshipCommon

public protocol GameRepository: Sendable {
    func setGame(_ game: Game) async
    func getGame(id: String) async -> Game?
    func all() async -> [Game]
}
