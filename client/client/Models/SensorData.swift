import Foundation

struct SensorData: Codable, Identifiable {
    var time: String
    var aqi: Int?
    var co2: Int?
    var humidity: Int?
    var tempF: Float?
    var id: String { time }

    var date: Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: time) ?? Date()
    }
}

struct SensorDataPoint: Codable, Identifiable {
    var date: Date
    var observation: Int
    var id: String
}
