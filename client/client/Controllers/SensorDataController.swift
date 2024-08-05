
import Foundation

@MainActor class SensorDataController: ObservableObject {
    static let shared = SensorDataController()

    @Published var loading = true

    @Published var aqi = DataMetric(dataPointCollection: DataPointCollection(), gradient: AqiGradientManager())
    @Published var temp = DataMetric(dataPointCollection: DataPointCollection(), gradient: TempGradientManager())
    @Published var co2 = DataMetric(dataPointCollection: DataPointCollection(), gradient: Co2GradientManager())
    @Published var humidity = DataMetric(dataPointCollection: DataPointCollection(), gradient: HumidityGradientManager())
    @Published var tvoc = DataMetric(dataPointCollection: DataPointCollection(), gradient: TvocGradientManager())

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
            aqi.dataPointCollection.data.append(DataPoint(date: data.date, observation: data.aqi ?? 0, id: data.id))
            temp.dataPointCollection.data.append(DataPoint(date: data.date, observation: Int(data.tempF ?? 0.0), id: data.id))
            co2.dataPointCollection.data.append(DataPoint(date: data.date, observation: data.co2 ?? 0, id: data.id))
            humidity.dataPointCollection.data.append(DataPoint(date: data.date, observation: data.humidity ?? 0, id: data.id))
            tvoc.dataPointCollection.data.append(DataPoint(date: data.date, observation: data.tvocIndex ?? 0, id: data.id))
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
