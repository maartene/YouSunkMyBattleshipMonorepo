import Foundation

@MainActor
public protocol DataProvider {
    func wsSend(data: Data) async throws
    func wsSyncSend(data: Data)
    func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void)
}

public struct DummyDataProvider: DataProvider {
    public init() { }
    public func wsSyncSend(data: Data) {}
    public func wsSend(data: Data) async throws {}
    public func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void) { }
}


@MainActor
public final class URLSessionDataProvider: DataProvider {
    private var task: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private var onReceive: ((Data) -> Void)?
    
    public init() { }
    
    public func wsSend(data: Data) async throws {
        let message = URLSessionWebSocketTask.Message.data(data)
        try await task?.send(message)
    }
    
    public func wsSyncSend(data: Data) {
        let message = URLSessionWebSocketTask.Message.data(data)
        task?.send(message) { _ in
        }
    }
    
    public func register(onReceive: @escaping (Data) -> Void) {
        self.onReceive = onReceive
    }
        
    public func connectToWebsocket(to url: URL, onReceive: @escaping (Data) -> Void) {
        task = URLSession.shared.webSocketTask(with: url)
        self.onReceive = onReceive
        task?.resume()
        startReceiveLoop()
    }

    deinit {
        receiveTask?.cancel()
        task?.cancel(with: .normalClosure, reason: nil)
    }
    
    private func startReceiveLoop() {
        receiveTask = Task {
            do {
                while !Task.isCancelled {
                    try await receive()
                }
            } catch {
                // handle errors (connection closed, cancellation, network issues)
                print("WebSocket receive loop ended with error:", error)
            }
        }
    }
        
    private func receive() async throws {
        let message = try await task?.receive()
        switch message {
        case .data(let data):
            self.onReceive?(data)
        case .string(let text):
            self.onReceive?(text.data(using: .utf8)!)
        @unknown default:
            fatalError("Unexpected message type: \(message)")
        }
    }
}
