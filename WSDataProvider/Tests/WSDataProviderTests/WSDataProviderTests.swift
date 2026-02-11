import Testing
@testable import WSDataProvider
import Foundation

@MainActor
@Suite final class WSDataProviderTests {
    var receivedStrings: [String] = []
    let dataProvider = URLSessionDataProvider()

    init() {
        dataProvider.connectToWebsocket(to: URL(string: "ws://localhost:8080")!) { data in
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
        try await dataProvider.wsSend(data: data)

        while receivedStrings.count < 2 {
            try await Task.sleep(nanoseconds: 1000)
        }

        #expect(receivedStrings.contains("Mirroring: Hello, World!"))
    }
    
    @Test func `can send and receive data synchronously`() async throws {
        let data = "Hello, World!".data(using: .utf8)!
        dataProvider.wsSyncSend(data: data)

        while receivedStrings.count < 2 {
            try await Task.sleep(nanoseconds: 1000)
        }

        #expect(receivedStrings.contains("Mirroring: Hello, World!"))
    }
    
    @Test func `can perform a GET request synchronously`() throws {
        struct TestData: Decodable, Equatable {
            let name: String
            let count: Int
        }
        let data = try #require(try dataProvider.syncGet(url: URL(string: "http://localhost:8080/hello")!))
        let receivedData = try JSONDecoder().decode(TestData.self, from: data)
        
        #expect(receivedData == TestData(name: "a test", count: 42))
    }
}
