//
//  DataProvider.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 26/01/2026.
//

import Foundation

protocol DataProvider {
    func fetch(_ endpoint: String) throws -> Data
    func post(_ data: Data, to endpoint: String) async throws
}

struct RemoteDataProvider: DataProvider {
    let baseURL: String

    func fetch(_ endpoint: String) throws -> Data {
        let url = URL(string: baseURL + "/" + endpoint)
        let data = try Data(contentsOf: url!)
        return data
    }

    func post(_ data: Data, to endpoint: String) async throws {
        let url = URL(string: baseURL + "/" + endpoint)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = data

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
}

// use websocat -s 8080 to implement a single server
final class WSDataProvider: DataProvider {
    struct ConnectMessage: Encodable {
        let type = "client.connect"
        let clientID = UUID().uuidString
    }

    func fetch(_ endpoint: String) throws -> Data {
        Data()
    }

    func post(_ data: Data, to endpoint: String) async throws {

    }

    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession: URLSession
    private var listenerTask: Task<Void, Never>?

    init() {
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration)
    }

    func connect() async {
        guard let url = URL(string: "ws://localhost:8080/game") else { return }

        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        // Send initial connect message (JSON) then start listening continuously
        do {
            let connectMessage = ConnectMessage()
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(connectMessage),
                let json = String(data: data, encoding: .utf8)
            {
                try await send(text: json)
            }
        } catch {
            print("Failed to send connect message: \(error)")
        }

        listenerTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.receive()
            } catch {
                print("Receive loop ended with error: \(error)")
            }
        }
    }

    func send(text: String) async throws {
        let message = URLSessionWebSocketTask.Message.string(text)
        try await webSocketTask?.send(message)
    }

    private func receive() async throws {
        guard let webSocketTask else { return }

        while true {
            do {
                let result = try await webSocketTask.receive()
                switch result {
                case .data(let data):
                    print(String(data: data, encoding: .utf8) ?? "unknown")
                case .string(let string):
                    print(string)
                @unknown default:
                    break
                }
            } catch {
                // Break the loop on error (connection closed, cancelled, etc.)
                throw error
            }
        }
    }

    func disconnect() {
        listenerTask?.cancel()
        listenerTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
}
