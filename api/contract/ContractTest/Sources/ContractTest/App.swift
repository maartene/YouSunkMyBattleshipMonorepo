//
//  main.swift
//  ContractTest
//
//  Created by Maarten Engels on 02/02/2026.
//

import Foundation
import ArgumentParser

@main
@MainActor struct App: AsyncParsableCommand {
    @Option var hostname = "127.0.0.1"
    @Option var port = "8080"
    @Option var mode = Mode.TwoPlayer
    @Flag var cpu = false
    
    
    mutating func run() async throws {
        print("Trying to connect to \(hostname):\(port) with mode \(mode)")
        
        let contractTest = ContractTest(hostname: hostname, port: port, mode: mode)
        try await contractTest.run()
    }
    
    enum Mode: String, ExpressibleByArgument {
        case TwoPlayer = "two-player"
        case VersusCPU = "cpu"
        case Driver = "driver"
    }
}
