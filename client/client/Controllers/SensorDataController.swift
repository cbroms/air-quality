
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

struct SensorDataMetric {
    var dataPointCollection = SensorDataPointCollection()
    var gradient: GradientManager
    var latestMetric: IntermediateGradientPosition?
}

class SensorDataController: ObservableObject {
    @Published var sensorData: [SensorData] = []
    @Published var loading = true

    @Published var aqi = SensorDataMetric(gradient: AqiGradientManager(maxValue: 0))
    @Published var temp = SensorDataMetric(gradient: TempGradientManager(maxValue: 0))
    @Published var co2 = SensorDataMetric(gradient: Co2GradientManager(maxValue: 0))
    @Published var humidity = SensorDataMetric(gradient: HumidityGradientManager(maxValue: 0))

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
            aqi.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.aqi ?? 0, id: data.id))
            temp.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: Int(data.tempF ?? 0.0), id: data.id))
            co2.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.co2 ?? 0, id: data.id))
            humidity.dataPointCollection.data.append(SensorDataPoint(date: data.date, observation: data.humidity ?? 0, id: data.id))
        }

        aqi.latestMetric = aqi.gradient.getIntermediateGradientPositionFromValue(value: aqi.dataPointCollection.getLatest().observation)
        co2.latestMetric = co2.gradient.getIntermediateGradientPositionFromValue(value: co2.dataPointCollection.getLatest().observation)
        temp.latestMetric = temp.gradient.getIntermediateGradientPositionFromValue(value: temp.dataPointCollection.getLatest().observation)
        humidity.latestMetric = humidity.gradient.getIntermediateGradientPositionFromValue(value: humidity.dataPointCollection.getLatest().observation)

        aqi.gradient.computeGradient(maxValue: aqi.dataPointCollection.getMax())
        co2.gradient.computeGradient(maxValue: co2.dataPointCollection.getMax())
        temp.gradient.computeGradient(maxValue: temp.dataPointCollection.getMax())
        humidity.gradient.computeGradient(maxValue: humidity.dataPointCollection.getMax())

        loading = false
    }
}
