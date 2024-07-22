
import Foundation

struct SensorDataPointCollection {
    var data: [SensorDataPoint] = []

    func getMax() -> Int {
        return data.max { a, b in a.observation < b.observation }?.observation ?? 0
    }

    func getMin() -> Int {
        return data.min { a, b in a.observation < b.observation }?.observation ?? 0
    }

    func getAvg() -> Int {
        var sum = data.reduce(0) { sum, a in a.observation + sum }
        return sum / data.count
    }

    func getLatest() -> SensorDataPoint {
        return data.last!
    }
}

struct SensorDataMetric {
    var dataPointCollection = SensorDataPointCollection()
    var gradient: GradientManager
    var latestMetric: IntermediateGradientPosition?
    var last60MinMetric: IntermediateGradientPosition?

    mutating func refreshMetrics() {
        gradient.recomputeGradients(maxValue: dataPointCollection.getMax(), minValue: dataPointCollection.getMin())
        latestMetric = gradient.getIntermediateGradientPositionFromValue(value: dataPointCollection.getLatest().observation)
        last60MinMetric = gradient.getIntermediateGradientPositionFromValue(value: dataPointCollection.getAvg())
    }
}

class SensorDataController: ObservableObject {
    @Published var sensorData: [SensorData] = []
    @Published var loading = true

    @Published var aqi = SensorDataMetric(gradient: AqiGradientManager())
    @Published var temp = SensorDataMetric(gradient: TempGradientManager())
    @Published var co2 = SensorDataMetric(gradient: Co2GradientManager())
    @Published var humidity = SensorDataMetric(gradient: HumidityGradientManager())
    @Published var tvoc = SensorDataMetric(gradient: TvocGradientManager())

    let sensorName = "airgradient:7aaa5e"

    enum FetchError: Error {
        case badRequest
        case badJSON
    }

    func getLast60Mins() async throws {
        loading = true
        let endIntervalDate = Date()
        let startIntervalDate = endIntervalDate.addingTimeInterval(-3600) // 60 mins ago
        let formatter = ISO8601DateFormatter()

        let startTime = formatter.string(from: startIntervalDate)
        let endTime = formatter.string(from: endIntervalDate)

        let url = URL(string: "https://air-quality.onedimension.net/sensors/\(sensorName)/measures/\(startTime)/\(endTime)/full")!

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        sensorData = try JSONDecoder().decode([SensorData].self, from: data)

        for data in sensorData {
            aqi.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.aqi ?? 0, id: data.id))
            temp.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: Int(data.tempF ?? 0.0), id: data.id))
            co2.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.co2 ?? 0, id: data.id))
            humidity.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.humidity ?? 0, id: data.id))
            tvoc.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.tvocIndex ?? 0, id: data.id))
        }

        aqi.refreshMetrics()
        temp.refreshMetrics()
        co2.refreshMetrics()
        humidity.refreshMetrics()
        tvoc.refreshMetrics()

        loading = false
    }
}
