# WSDataProvider

A small WebSocket-backed implementation of the `DataProvider` protocol used in this workspace.

## DataProvider protocol

- `@MainActor protocol DataProvider` exposes two methods:
	- `func send(data: Data) async throws` — send binary data over the connection.
	- `func register(onReceive: @escaping (Data) -> Void)` — register a callback to receive incoming data.

The provided `WSDataProvider` implements this protocol and:
- Open a WebSocket connection on `init(url:)`.
- Calls the registered `onReceive` callback for incoming messages.
- Cancels the receive task and closes the socket on `deinit`.

## How to use `WSDataProvider`

Example usage in Swift:

```swift
let url = URL(string: "ws://localhost:9000")!
let provider = WSDataProvider(url: url)

provider.register { data in
		// handle received data
		print("Received \(data.count) bytes")
}

Task {
		let payload = Data([0x01, 0x02])
		try await provider.send(data: payload)
}
```

Notes:
- `send` is `async throws` — call it from an async context and handle errors.
- Register your receive handler before or soon after creating the provider to avoid missed messages.

## Running tests

The test suite for `WSDataProvider` requires the mirror WebSocket server to be running. 

### Option 1: test script (recommended)
Run the provided test script. This makes sure the mirror server is started before the tests are run. Note, this requires `Docker` (or an alternative like `PodMan`).
```bash
./run_tests.sh
```

### Option 2: start tests manually
Start the mirror server before running tests:

```bash
./start_ws_mirror.sh
```

And then run the tests:

```bash
swift test
```