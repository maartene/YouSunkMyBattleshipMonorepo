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
    @Flag var cpu = false
    
    
    mutating func run() async throws {
        print("Trying to connect to \(hostname):\(port)")
        
        let contractTest = ContractTest(hostname: hostname, port: port, useCPUOpponent: cpu)
        try await contractTest.run()
    }
}
