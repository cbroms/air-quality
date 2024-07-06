
import Foundation

struct SensorDataPointCollection {
    var data: [SensorDataPoint] = []

    func getMax() -> Int {
        return data.max { a, b in a.observation < b.observation }?.observation ?? 0
    }

    func getLatest() -> SensorDataPoint {
        return data.last!
    }
}

class SensorDataController: ObservableObject {
    @Published var sensorData: [SensorData] = []
    @Published var aqiData = SensorDataPointCollection()
    @Published var tempData = SensorDataPointCollection()
    @Published var co2Data = SensorDataPointCollection()
    @Published var humidityData = SensorDataPointCollection()
    @Published var loading = true

    @Published var aqiGradient = AqiGradientManager(maxValue: 0)
    @Published var tempGradient = TempGradientManager(maxValue: 0)
    @Published var co2Gradient = Co2GradientManager(maxValue: 0)
    @Published var humidityGradient = HumidityGradientManager(maxValue: 0)

    @Published var latestAqiMetric: IntermediateGradientPosition? = nil
    @Published var latestTempMetric: IntermediateGradientPosition? = nil
    @Published var latestCo2Metric: IntermediateGradientPosition? = nil
    @Published var latestHumidityMetric: IntermediateGradientPosition? = nil

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

        let url = URL(string: "https://air-quality.onedimension.net/sensors/\(sensorName)/measures/\(startTime)/\(endTime)/simple")!

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        sensorData = try JSONDecoder().decode([SensorData].self, from: data)

        for data in sensorData {
            aqiData.data.append(SensorDataPoint(date: data.date, observation: data.aqi ?? 0, id: data.id))
            tempData.data.append(SensorDataPoint(date: data.date, observation: Int(data.tempF ?? 0.0), id: data.id))
            co2Data.data.append(SensorDataPoint(date: data.date, observation: data.co2 ?? 0, id: data.id))
            humidityData.data.append(SensorDataPoint(date: data.date, observation: data.humidity ?? 0, id: data.id))
        }

        latestAqiMetric = aqiGradient.getIntermediateGradientPositionFromValue(value: aqiData.getLatest().observation)
        latestCo2Metric = co2Gradient.getIntermediateGradientPositionFromValue(value: co2Data.getLatest().observation)
        latestTempMetric = tempGradient.getIntermediateGradientPositionFromValue(value: tempData.getLatest().observation)
        latestHumidityMetric = humidityGradient.getIntermediateGradientPositionFromValue(value: humidityData.getLatest().observation)

        aqiGradient.computeGradient(maxValue: aqiData.getMax())
        co2Gradient.computeGradient(maxValue: co2Data.getMax())
        tempGradient.computeGradient(maxValue: tempData.getMax())
        humidityGradient.computeGradient(maxValue: humidityData.getMax())

        loading = false
    }
}
