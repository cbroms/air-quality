import Fluent
import Vapor

struct PostSensorUpdate: Content {
  var wifi: Int?
  var rco2: Int?
  var pm01: Int?
  var pm02: Int?
  var pm10: Int?
  var pm003_count: Int?
  var tvoc_index: Int?
  var nox_index: Int?
  var atmp: Float?
  var rhum: Int?
}

func routes(_ app: Application) throws {
  app.get { req async in
    "Hello world!"
  }

  app.post("sensors", ":sensorName", "measures") { req async throws -> HTTPStatus in
    guard let sensorName = req.parameters.get("sensorName", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor name")
    }
    guard let postSensorUpdate = try? req.content.decode(PostSensorUpdate.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor update format")
    }

    // save the sensor update in the database
    var sensor = try? await Sensor.query(on: req.db)
      .filter(\.$name == sensorName)
      .first()

    if sensor == nil {
      let newSensor = Sensor(name: sensorName)
      try await newSensor.save(on: req.db)
      sensor = newSensor
    }

    guard let sensorId = try sensor?.requireID() else {
      throw Abort(.internalServerError)
    }

    let sensorUpdate = SensorUpdate(
      wifi: postSensorUpdate.wifi,
      rco2: postSensorUpdate.rco2,
      pm01: postSensorUpdate.pm01,
      pm02: postSensorUpdate.pm02,
      pm10: postSensorUpdate.pm10,
      pm003Count: postSensorUpdate.pm003_count,
      tvocIndex: postSensorUpdate.tvoc_index,
      noxIndex: postSensorUpdate.nox_index,
      atmp: postSensorUpdate.atmp,
      rhum: postSensorUpdate.rhum,
      sensorID: sensorId
    )

    try await sensorUpdate.save(on: req.db)

    req.logger.info("Received sensor update for sensor \(sensorName): \(postSensorUpdate)")
    return .ok
  }

  app.get("sensors", ":sensorName") { req async throws -> [SensorUpdate] in

    guard let sensorName = req.parameters.get("sensorName", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor name")
    }

    guard
      let sensor = try await Sensor.query(on: req.db)
        .filter(\.$name == sensorName)
        .first()
    else {
      throw Abort(.notFound, reason: "Could not find sensor \(sensorName)")
    }

    let sensorId = try sensor.requireID()

    let sensorUpdates = try await SensorUpdate.query(on: req.db)
      .filter(\.$sensor.$id == sensorId)
      .all()

    return sensorUpdates
  }
}
