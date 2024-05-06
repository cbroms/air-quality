import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { req async throws -> HTTPStatus in
    return .ok
  }

  try app.register(collection: SensorController())
}
