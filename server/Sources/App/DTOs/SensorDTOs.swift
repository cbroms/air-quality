import Vapor

struct PostMeasuresDTO: Content {
  var wifi: Int?
  var rco2: Int?
  var pm01: Int?
  var pm02: Int?
  var pm10: Int?
  var pm003_count: Int?
  var tvoc_index: Int?
  var nox_index: Int?
  var atmp: Float?
  var rhum: Int?
}

struct GetSimpleMeasuresInRangeDTO: Content {
  var time: Date
  var aqi: Int?
  var co2: Int?
  var humidity: Int?
  var tempF: Float?
}

struct GetFullMeasuresInRangeDTO: Content {
  var time: Date
  var aqi: Int?
  var co2: Int?
  var humidity: Int?
  var tempF: Float?
  var pm02: Int?
  var pm10: Int?
  var tvocIndex: Int?
  var noxIndex: Int?
}
