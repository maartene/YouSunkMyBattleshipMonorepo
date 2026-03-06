import GameRepository
import Vapor
import YouSunkMyBattleshipCommon

let app = try await Application.make(.detect())
try configure(app)

try await app.execute()

func configure(_ app: Application) throws {
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8081
    
    app.get { req in
        return "Health check OK"
    }
}
