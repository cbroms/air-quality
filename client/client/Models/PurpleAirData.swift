import Foundation

struct PurpleAirData: Codable, Identifiable {
    var timestamp: String
    var humidity: Double?
    var temperature: Double?
    var id: String { timestamp }

    var date: Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: timestamp) ?? Date()
    }

    init(timestamp: String, humidity: Double, temperature: Double) {
        self.timestamp = timestamp
        self.humidity = humidity
        self.temperature = temperature
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        timestamp = try container.decode(String.self)
        humidity = try container.decode(Double?.self)
        temperature = try container.decode(Double?.self)
    }

    enum OperationError: Error {
        case timestampMismatch
        case nilInput
    }

    static func +(lhs: PurpleAirData, rhs: PurpleAirData) throws -> PurpleAirData {
        if lhs.timestamp != rhs.timestamp {
            throw OperationError.timestampMismatch
        }

        guard let lhsHumidity = lhs.humidity else { throw OperationError.nilInput }
        guard let rhsHumidity = rhs.humidity else { throw OperationError.nilInput }
        guard let lhsTemperature = lhs.temperature else { throw OperationError.nilInput }
        guard let rhsTemperature = rhs.temperature else { throw OperationError.nilInput }

        return PurpleAirData(
            timestamp: lhs.timestamp,
            humidity: lhsHumidity + rhsHumidity,
            temperature: lhsTemperature + rhsTemperature
        )
    }

    static func /(lhs: PurpleAirData, rhs: Double) throws -> PurpleAirData {
        guard let lhsHumidity = lhs.humidity else { throw OperationError.nilInput }
        guard let lhsTemperature = lhs.temperature else { throw OperationError.nilInput }

        return PurpleAirData(
            timestamp: lhs.timestamp,
            humidity: lhsHumidity / rhs,
            temperature: lhsTemperature / rhs
        )
    }
}

struct PurpleAirSensorHistoryResp: Codable {
    var data: [PurpleAirData]
}

struct PurpleAirSensor: Codable {
    var index: Int
    var latitude: Double
    var longitude: Double

    init(index: Int, latitude: Double, longitude: Double) {
        self.index = index
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        index = try container.decode(Int.self)
        latitude = try container.decode(Double.self)
        longitude = try container.decode(Double.self)
    }
}

struct PurpleAirSensorsResp: Codable {
    var data: [PurpleAirSensor]
}
