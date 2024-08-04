
import Foundation

struct SensorDataMetric {
    var dataPointCollection: SensorDataPointCollection
    var gradient: GradientManager
    var latestUpdateTime: Date?
    var latestMetric: IntermediateGradientPosition?
    var last60MinMetric: IntermediateGradientPosition?

    mutating func refreshMetrics() {
        gradient.recomputeGradients(maxValue: dataPointCollection.getMax(), minValue: dataPointCollection.getMin())
        let latest = dataPointCollection.getLatest()
        latestMetric = gradient.getIntermediateGradientPositionFromValue(value: latest.observation)
        latestUpdateTime = latest.date
        last60MinMetric = gradient.getIntermediateGradientPositionFromValue(value: dataPointCollection.getAvg())
    }
}

@MainActor class SensorDataController: ObservableObject {
    static let shared = SensorDataController()

    @Published var loading = true

    @Published var aqi = SensorDataMetric(dataPointCollection: SensorDataPointCollection(), gradient: AqiGradientManager())
    @Published var temp = SensorDataMetric(dataPointCollection: SensorDataPointCollection(), gradient: TempGradientManager())
    @Published var co2 = SensorDataMetric(dataPointCollection: SensorDataPointCollection(), gradient: Co2GradientManager())
    @Published var humidity = SensorDataMetric(dataPointCollection: SensorDataPointCollection(), gradient: HumidityGradientManager())
    @Published var tvoc = SensorDataMetric(dataPointCollection: SensorDataPointCollection(), gradient: TvocGradientManager())

    let sensorName = "airgradient:7aaa5e"

    enum FetchError: Error {
        case badRequest
        case badResponse
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

        guard let (data, response) = try? await URLSession.shared.data(from: url) else { throw FetchError.badRequest }
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badResponse }

        guard let sensorData = try? JSONDecoder().decode([SensorData].self, from: data) else { throw FetchError.badJSON }

        // remove any existing data
        aqi.dataPointCollection.reset()
        temp.dataPointCollection.reset()
        tvoc.dataPointCollection.reset()
        co2.dataPointCollection.reset()
        humidity.dataPointCollection.reset()

        // add the new data points
        for data in sensorData {
            aqi.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.aqi ?? 0, id: data.id))
            temp.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: Int(data.tempF ?? 0.0), id: data.id))
            co2.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.co2 ?? 0, id: data.id))
            humidity.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.humidity ?? 0, id: data.id))
            tvoc.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.tvocIndex ?? 0, id: data.id))
        }

        // recalculate the latest vals and gradients
        aqi.refreshMetrics()
        temp.refreshMetrics()
        co2.refreshMetrics()
        humidity.refreshMetrics()
        tvoc.refreshMetrics()

        loading = false
    }
}
