import Fluent

struct CreateSensorUpdate: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("sensor_updates")
      .id()
      .field("wifi", .int)
      .field("rco2", .int)
      .field("pm01", .int)
      .field("pm02", .int)
      .field("pm10", .int)
      .field("pm003_count", .int)
      .field("tvoc_index", .int)
      .field("nox_index", .int)
      .field("atmp", .float)
      .field("rhum", .int)
      .field("time", .datetime)
      .field("sensor_id", .uuid, .required, .references("sensors", "id"))
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("sensor_updates").delete()
  }
}
