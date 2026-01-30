import Testing
@testable import WSDataProvider
import Foundation

@MainActor
@Suite final class WSDataProviderTests {
    var receivedStrings: [String] = []
    let dataProvider = WSDataProvider(url: URL(string: "ws://localhost:8080")!)

    init() {
        dataProvider.register { data in
            self.receivedStrings.append(String(data: data, encoding: .utf8) ?? "Not able to convert to string")
        }
    }

    @Test func `can connect`() async throws {
        while receivedStrings.isEmpty {
            try await Task.sleep(nanoseconds: 1000)
        }
    
        #expect(receivedStrings.contains("Welcome to the WebSocket echo server!"))
    }   

    @Test func `can send and receive data`() async throws {
        let data = "Hello, World!".data(using: .utf8)!
        try await dataProvider.send(data: data)

        while receivedStrings.count < 2 {
            try await Task.sleep(nanoseconds: 1000)
        }

        #expect(receivedStrings.contains("Mirroring: Hello, World!"))
    }
}
