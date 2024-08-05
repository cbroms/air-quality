import Foundation

struct SensorData: Codable, Identifiable {
    var time: String
    var aqi: Int?
    var co2: Int?
    var humidity: Int?
    var tempF: Float?
    var pm02: Int?
    var pm10: Int?
    var tvocIndex: Int?
    var noxIndex: Int?
    var id: String { time }

    var date: Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: time) ?? Date()
    }
}
