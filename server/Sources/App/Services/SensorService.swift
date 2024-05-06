import Fluent
import Vapor

struct SensorService {

  func getOrCreateSensor(for sensorName: String, on db: Database) async throws -> UUID {
    var sensor = try await Sensor.query(on: db)
      .filter(\.$name == sensorName)
      .first()
    if sensor == nil {
      let newSensor = Sensor(name: sensorName)
      try await newSensor.save(on: db)
      sensor = newSensor
    }

    guard let sensorId = try sensor?.requireID() else {
      throw Abort(.internalServerError)
    }

    return sensorId
  }

  func getSensor(for sensorName: String, on db: Database) async throws -> UUID {
    let sensor = try await Sensor.query(on: db)
      .filter(\.$name == sensorName)
      .first()

    if sensor == nil {
      throw Abort(.notFound, reason: "Sensor not found")
    }

    guard let sensorId = try sensor?.requireID() else {
      throw Abort(.internalServerError)
    }

    return sensorId
  }

  func createSensorUpdate(for sensorId: UUID, with postMeasures: PostMeasuresDTO, on db: Database)
    async throws
  {
    let sensorUpdate = SensorUpdate(
      co2: postMeasures.rco2,
      aqi: pm2ToAqi(Float(postMeasures.pm02 ?? 0)),
      pm02: postMeasures.pm02,
      pm10: postMeasures.pm10,
      tvocIndex: postMeasures.tvoc_index,
      noxIndex: postMeasures.nox_index,
      tempF: celsiusToFahrenheit(postMeasures.atmp ?? 0.0),
      humidity: postMeasures.rhum,
      sensorID: sensorId
    )
    try await sensorUpdate.save(on: db)
  }

  func getFullMeasuresInRange(
    for sensorId: UUID,
    from start: String,
    to end: String,
    on db: Database
  ) async throws -> [GetFullMeasuresInRangeDTO] {

    let dateFormatter = ISO8601DateFormatter()

    let startTimestamp = dateFormatter.date(from: start)
    let endTimestamp = dateFormatter.date(from: end)

    if startTimestamp == nil {
      throw Abort(.badRequest, reason: "Invalid start time format")
    }

    if endTimestamp == nil {
      throw Abort(.badRequest, reason: "Invalid end time format")
    }

    let sensorUpdates = try await SensorUpdate.query(on: db)
      .filter(\.$time >= startTimestamp)
      .filter(\.$time <= endTimestamp)
      .filter(\.$sensor.$id == sensorId)
      .field(\.$time)
      .field(\.$aqi)
      .field(\.$co2)
      .field(\.$humidity)
      .field(\.$tempF)
      .field(\.$pm02)
      .field(\.$pm10)
      .field(\.$tvocIndex)
      .field(\.$noxIndex)
      .all()

    var fullMeasures: [GetFullMeasuresInRangeDTO] = []
    for sensorUpdate in sensorUpdates {
      let fullMeasure = GetFullMeasuresInRangeDTO(
        time: sensorUpdate.time ?? Date(),
        aqi: sensorUpdate.aqi,
        co2: sensorUpdate.co2,
        humidity: sensorUpdate.humidity,
        tempF: sensorUpdate.tempF,
        pm02: sensorUpdate.pm02,
        pm10: sensorUpdate.pm10,
        tvocIndex: sensorUpdate.tvocIndex,
        noxIndex: sensorUpdate.noxIndex
      )
      fullMeasures.append(fullMeasure)
    }

    return fullMeasures
  }

  func getSimpleMeasuresInRange(
    for sensorId: UUID,
    from start: String,
    to end: String,
    on db: Database
  ) async throws -> [GetSimpleMeasuresInRangeDTO] {

    let dateFormatter = ISO8601DateFormatter()

    let startTimestamp = dateFormatter.date(from: start)
    let endTimestamp = dateFormatter.date(from: end)

    if startTimestamp == nil {
      throw Abort(.badRequest, reason: "Invalid start time format")
    }

    if endTimestamp == nil {
      throw Abort(.badRequest, reason: "Invalid end time format")
    }

    let sensorUpdates = try await SensorUpdate.query(on: db)
      .filter(\.$time >= startTimestamp)
      .filter(\.$time <= endTimestamp)
      .filter(\.$sensor.$id == sensorId)
      .field(\.$time)
      .field(\.$aqi)
      .field(\.$co2)
      .field(\.$humidity)
      .field(\.$tempF)
      .all()

    var simpleMeasures: [GetSimpleMeasuresInRangeDTO] = []
    for sensorUpdate in sensorUpdates {
      let simpleMeasure = GetSimpleMeasuresInRangeDTO(
        time: sensorUpdate.time ?? Date(),
        aqi: sensorUpdate.aqi,
        co2: sensorUpdate.co2,
        humidity: sensorUpdate.humidity,
        tempF: sensorUpdate.tempF
      )
      simpleMeasures.append(simpleMeasure)
    }

    return simpleMeasures
  }

}
