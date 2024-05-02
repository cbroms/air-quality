import Fluent
import Vapor

final class SensorUpdate: Model, Content {
  static let schema = "sensor_updates"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "wifi")
  var wifi: String?

  @Field(key: "rco2")
  var rco2: Float?

  @Field(key: "pm01")
  var pm01: Float?

  @Field(key: "pm02")
  var pm02: Float?

  @Field(key: "pm10")
  var pm10: Float?

  @Field(key: "pm003_count")
  var pm003Count: Float?

  @Field(key: "tvoc_index")
  var tvocIndex: Float?

  @Field(key: "nox_index")
  var noxIndex: Float?

  @Field(key: "atmp")
  var atmp: Float?

  @Field(key: "rhum")
  var rhum: Float?

  @Parent(key: "sensor_id")
  var sensor: Sensor

  @Timestamp(key: "time", on: .create)
  var time: Date?

  init() {}

  init(
    id: UUID? = nil, wifi: String?, rco2: Float?, pm01: Float?, pm02: Float?, pm10: Float?,
    pm003Count: Float?, tvocIndex: Float?, noxIndex: Float?, atmp: Float?, rhum: Float?,
    sensorID: Sensor.IDValue
  ) {
    self.id = id
    self.wifi = wifi
    self.rco2 = rco2
    self.pm01 = pm01
    self.pm02 = pm02
    self.pm10 = pm10
    self.pm003Count = pm003Count
    self.tvocIndex = tvocIndex
    self.noxIndex = noxIndex
    self.atmp = atmp
    self.rhum = rhum
    self.$sensor.id = sensorID
  }

}
