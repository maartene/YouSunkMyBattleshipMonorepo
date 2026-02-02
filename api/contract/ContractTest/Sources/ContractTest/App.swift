//
//  main.swift
//  ContractTest
//
//  Created by Maarten Engels on 02/02/2026.
//

@main
@MainActor struct App {
    static func main() async throws {
        var contractTest = await ContractTest()
        try await contractTest.run()
    }
}
