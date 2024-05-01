import Fluent

struct CreateSensorUpdate: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("sensor_updates")
      .id()
      .field("wifi", .string)
      .field("rco2", .float)
      .field("pm01", .float)
      .field("pm02", .float)
      .field("pm10", .float)
      .field("pm003_count", .float)
      .field("tvoc_index", .float)
      .field("nox_index", .float)
      .field("atmp", .float)
      .field("rhum", .float)
      .field("time", .datetime)
      .field("sensor_id", .uuid, .required, .references("sensors", "id"))
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("sensor_updates").delete()
  }
}
