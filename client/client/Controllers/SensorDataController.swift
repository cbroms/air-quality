
import Foundation

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
    static let shared = SensorDataController()

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

        DispatchQueue.main.async {
            for data in self.sensorData {
                self.aqi.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.aqi ?? 0, id: data.id))
                self.temp.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: Int(data.tempF ?? 0.0), id: data.id))
                self.co2.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.co2 ?? 0, id: data.id))
                self.humidity.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.humidity ?? 0, id: data.id))
                self.tvoc.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.tvocIndex ?? 0, id: data.id))
            }

            self.aqi.refreshMetrics()
            self.temp.refreshMetrics()
            self.co2.refreshMetrics()
            self.humidity.refreshMetrics()
            self.tvoc.refreshMetrics()

            self.loading = false
        }
    }
}
