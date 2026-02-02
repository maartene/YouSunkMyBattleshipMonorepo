//
//  main.swift
//  ContractTest
//
//  Created by Maarten Engels on 02/02/2026.
//

import Foundation

@main
@MainActor struct App {
    static func main() async throws {
        let arguments = CommandLine.arguments
        
        var hostname = "127.0.0.1"
        var port = "8080"
        
        switch arguments.count {
        case 1:
            break
        case 2:
            hostname = arguments[1]
        case 3:
            hostname = arguments[1]
            port = arguments[2]
        default:
            fatalError("Expected 0, 1 or 2 arguments when launching executable.")
        }
        
        let contractTest = ContractTest(hostname: hostname, port: port)
        try await contractTest.run()
    }
}
