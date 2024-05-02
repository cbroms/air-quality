import Fluent
import Vapor

final class SensorUpdate: Model, Content {
  static let schema = "sensor_updates"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "wifi")
  var wifi: Int?

  @Field(key: "rco2")
  var rco2: Int?

  @Field(key: "pm01")
  var pm01: Int?

  @Field(key: "pm02")
  var pm02: Int?

  @Field(key: "pm10")
  var pm10: Int?

  @Field(key: "pm003_count")
  var pm003Count: Int?

  @Field(key: "tvoc_index")
  var tvocIndex: Int?

  @Field(key: "nox_index")
  var noxIndex: Int?

  @Field(key: "atmp")
  var atmp: Float?

  @Field(key: "rhum")
  var rhum: Int?

  @Parent(key: "sensor_id")
  var sensor: Sensor

  @Timestamp(key: "time", on: .create)
  var time: Date?

  init() {}

  init(
    id: UUID? = nil, wifi: Int?, rco2: Int?, pm01: Int?, pm02: Int?, pm10: Int?,
    pm003Count: Int?, tvocIndex: Int?, noxIndex: Int?, atmp: Float?, rhum: Int?,
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
