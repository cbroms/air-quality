import Fluent
import Vapor

final class SensorUpdate: Model, Content {
  static let schema = "sensor_updates"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "co2")
  var co2: Int?

  @Field(key: "aqi")
  var aqi: Int?

  @Field(key: "pm02")
  var pm02: Int?

  @Field(key: "pm10")
  var pm10: Int?

  @Field(key: "tvoc_index")
  var tvocIndex: Int?

  @Field(key: "nox_index")
  var noxIndex: Int?

  @Field(key: "temp_f")
  var tempF: Float?

  @Field(key: "humidity")
  var humidity: Int?

  @Parent(key: "sensor_id")
  var sensor: Sensor

  @Timestamp(key: "time", on: .create)
  var time: Date?

  init() {}

  init(
    id: UUID? = nil, co2: Int?, aqi: Int?, pm02: Int?, pm10: Int?, tvocIndex: Int?, noxIndex: Int?,
    tempF: Float?,
    humidity: Int?,
    sensorID: Sensor.IDValue
  ) {
    self.id = id
    self.co2 = co2
    self.aqi = aqi
    self.pm02 = pm02
    self.pm10 = pm10
    self.tvocIndex = tvocIndex
    self.noxIndex = noxIndex
    self.tempF = tempF
    self.humidity = humidity
    self.$sensor.id = sensorID
  }
}
