import Fluent
import Vapor

final class SensorController: RouteCollection {

  let sensorService = SensorService()

  func boot(routes: RoutesBuilder) throws {
    let sensors = routes.grouped("sensors")
    sensors.group(":sensorName", "measures") { sensor in
      sensor.post(use: postMeasures).description("Post new measures for a sensor")
      sensor.group(":start", ":end") { range in
        range.get("simple", use: getSimpleMeasuresInRange).description(
          "Get AQI, temp, CO2, and humidity measures for a sensor in a time range")
        range.get("full", use: getFullMeasuresInRange).description(
          "Get all measures for a sensor in a time range")
      }
    }
  }

  func postMeasures(req: Request) async throws -> HTTPStatus {
    guard let sensorName = req.parameters.get("sensorName", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor name")
    }
    guard let postMeasures = try? req.content.decode(PostMeasuresDTO.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor update format")
    }
    let sensorId = try await sensorService.getOrCreateSensor(for: sensorName, on: req.db)
    try await sensorService.createSensorUpdate(for: sensorId, with: postMeasures, on: req.db)
    return .ok
  }

  func getFullMeasuresInRange(req: Request) async throws -> [GetFullMeasuresInRangeDTO] {
    guard let sensorName = req.parameters.get("sensorName", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor name")
    }
    guard let startTime = req.parameters.get("start", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid start time")
    }
    guard let endTime = req.parameters.get("end", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid end time")
    }

    let sensorId = try await sensorService.getSensor(for: sensorName, on: req.db)
    let sensorUpdates = try await sensorService.getFullMeasuresInRange(
      for: sensorId,
      from: startTime,
      to: endTime,
      on: req.db
    )
    return sensorUpdates
  }

  func getSimpleMeasuresInRange(req: Request) async throws -> [GetSimpleMeasuresInRangeDTO] {
    guard let sensorName = req.parameters.get("sensorName", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid sensor name")
    }
    guard let startTime = req.parameters.get("start", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid start time")
    }
    guard let endTime = req.parameters.get("end", as: String.self) else {
      throw Abort(.badRequest, reason: "Invalid end time")
    }

    let sensorId = try await sensorService.getSensor(for: sensorName, on: req.db)
    let sensorUpdates = try await sensorService.getSimpleMeasuresInRange(
      for: sensorId,
      from: startTime,
      to: endTime,
      on: req.db
    )
    return sensorUpdates
  }
}
