import Foundation

struct SensorData: Codable, Identifiable {
    var time: String
    var aqi: Int?
    var co2: Int?
    var humidity: Int?
    var tempF: Float?
    var id: String { time }
}
