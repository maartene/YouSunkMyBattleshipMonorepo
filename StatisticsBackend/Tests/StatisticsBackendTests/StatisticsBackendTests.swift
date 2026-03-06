import Testing
import VaporTesting
@testable import StatisticsBackend

@Test func `server health check`() async throws {
    try await withApp(configure: configure) { app in
        try await app.testing().test(.GET, "/") { res in
            #expect(res.status == .ok)
        }
    }
}
