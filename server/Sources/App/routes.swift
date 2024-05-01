import Fluent
import Vapor

struct PostSensorUpdate: Content {
  var wifi: String?
  var rco2: Float?
  var pm01: Float?
  var pm02: Float?
  var pm10: Float?
  var pm003_count: Float?
  var tvoc_index: Float?
  var nox_index: Float?
  var atmp: Float?
  var rhum: Float?

  // Custom initializer to parse strings to floats
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    wifi = try container.decodeIfPresent(String.self, forKey: .wifi)
    rco2 = Float(try container.decodeIfPresent(String.self, forKey: .rco2) ?? "")
    pm01 = Float(try container.decodeIfPresent(String.self, forKey: .pm01) ?? "")
    pm02 = Float(try container.decodeIfPresent(String.self, forKey: .pm02) ?? "")
    pm10 = Float(try container.decodeIfPresent(String.self, forKey: .pm10) ?? "")
    pm003_count = Float(try container.decodeIfPresent(String.self, forKey: .pm003_count) ?? "")
    tvoc_index = Float(try container.decodeIfPresent(String.self, forKey: .tvoc_index) ?? "")
    nox_index = Float(try container.decodeIfPresent(String.self, forKey: .nox_index) ?? "")
    atmp = Float(try container.decodeIfPresent(String.self, forKey: .atmp) ?? "")
    rhum = Float(try container.decodeIfPresent(String.self, forKey: .rhum) ?? "")
  }
}

extension PostSensorUpdate {
  private enum CodingKeys: String, CodingKey {
    case wifi, rco2, pm01, pm02, pm10, pm003_count, tvoc_index, nox_index, atmp, rhum
  }
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
    
//    app.get("sensors", ":sensorName") { req async throws -> HTTPStatus in
//        
//        guard let sensorName = req.parameters.get("sensorName", as: String.self) else {
//            throw Abort(.badRequest, reason: "Invalid sensor name")
//        }
//        
//        guard let sensor = try await Sensor.query(on: req.db)
//            .filter(\.$name == sensorName)
//            .first() else {
//            throw Abort(.notFound, reason: "Could not find sensor \(sensorName)")
//        }
//        
//        let sensorId = try sensor.requireID()
//        
//        guard let sensorUpdates = try await SensorUpdate.query(on: req.db)
//            .with(\.$sensor)
//            .all()
//        else {
//            throw Abort(.notFound, reason: "Could not find any updates for sensor \(sensorName)")
//        }
//        
//        
//        
//        
//    }
}
