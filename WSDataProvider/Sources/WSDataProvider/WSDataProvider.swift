import Foundation

@MainActor
protocol DataProvider {
    func send(data: Data) async throws
    func register(onReceive: @escaping (Data) -> Void)
}

@MainActor
final class WSDataProvider: DataProvider {
    private let task: URLSessionWebSocketTask
    private var receiveTask: Task<Void, Never>?
    private var onReceive: ((Data) -> Void)?
    
    func send(data: Data) async throws {
        let message = URLSessionWebSocketTask.Message.data(data)
        try await task.send(message)
    }
    
    func register(onReceive: @escaping (Data) -> Void) {
        self.onReceive = onReceive
    }
        
    init(url: URL) {
        task = URLSession.shared.webSocketTask(with: url)
        task.resume()
        startReceiveLoop()
    }

    deinit {
        receiveTask?.cancel()
        task.cancel(with: .normalClosure, reason: nil)
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
        let message = try await task.receive()
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
