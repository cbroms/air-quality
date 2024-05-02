import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // set up the database
  app.databases.use(.sqlite(.file("data/db.sqlite")), as: .sqlite)
  app.migrations.add(CreateSensor())
  app.migrations.add(CreateSensorUpdate())
  try await app.autoMigrate()

  // register routes
  try routes(app)
}
