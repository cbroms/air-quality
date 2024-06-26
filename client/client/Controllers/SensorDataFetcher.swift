

import Foundation

class SensorDataFetcher: ObservableObject {
    @Published var sensorData: [SensorData] = []
    @Published var aqiData: [SensorDataPoint] = []
    @Published var tempData: [SensorDataPoint] = []
    @Published var co2Data: [SensorDataPoint] = []
    @Published var humidityData: [SensorDataPoint] = []
    @Published var loading = true

    let sensorName = "airgradient:7aaa5e"

    enum FetchError: Error {
        case badRequest
        case badJSON
    }

    func getLast60Mins() async throws {
        loading = true
        let endIntervalDate = Date()
        let startIntervalDate = endIntervalDate.addingTimeInterval(-600) // 60 mins ago
        let formatter = ISO8601DateFormatter()

        let startTime = formatter.string(from: startIntervalDate)
        let endTime = formatter.string(from: endIntervalDate)

        let url = URL(string: "http://desertsage.local:5001/sensors/\(sensorName)/measures/\(startTime)/\(endTime)/simple")!

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        sensorData = try JSONDecoder().decode([SensorData].self, from: data)

        for data in sensorData {
            aqiData.append(SensorDataPoint(date: data.date, observation: data.aqi ?? 0, id: data.id))
            tempData.append(SensorDataPoint(date: data.date, observation: Int(data.tempF ?? 0.0), id: data.id))
            co2Data.append(SensorDataPoint(date: data.date, observation: data.co2 ?? 0, id: data.id))
            humidityData.append(SensorDataPoint(date: data.date, observation: data.humidity ?? 0, id: data.id))
        }

        loading = false
    }
}
