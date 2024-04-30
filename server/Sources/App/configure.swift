import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // set up the database
  try app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  // register routes
  try routes(app)
}