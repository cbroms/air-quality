import Fluent
import Vapor

final class Sensor: Model {
  static let schema = "sensors"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String

  init() {}

  init(id: UUID? = nil, name: String) {
    self.id = id
    self.name = name
  }
}
