import Vapor

struct SensorUpdate: Content {
  var wifi: String?
  var rco2: String?
  var pm01: String?
  var pm02: String?
  var pm10: String?
  var pm003_count: String?
  var tvoc_index: String?
  var nox_index: String?
  var atmp: String?
  var rhum: String?
}

func routes(_ app: Application) throws {
  app.get { req async in
    "Hello world!"
  }

  app.post("sensors", ":id", "measures") { req async throws -> HTTPStatus in
    guard let id = req.parameters.get("id", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor id")
    }
    guard let sensorUpdate = try? req.content.decode(SensorUpdate.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor update format")
    }

    req.logger.info("Received sensor update for sensor \(id): \(sensorUpdate)")
    return .ok
  }
}
