
import CoreLocation
import Foundation

@MainActor class PurpleAirDataController: ObservableObject {
    static let shared = PurpleAirDataController()

    @Published var loading = true

    @Published var temp = DataMetric(dataPointCollection: DataPointCollection(), gradient: TempGradientManager())
    @Published var humidity = DataMetric(dataPointCollection: DataPointCollection(), gradient: HumidityGradientManager())

    enum FetchDataError: Error {
        case badRequest
        case badResponse
        case badJSON
        case noSensors
        case sensorHistoryMismatchedLength
    }

    func identifySensors(apiKey: String, location: CLLocation, maxNumSensors: Int, maxSensorDistance: Double) async throws -> [PurpleAirSensor] {
        let nwLoc = location.addVector(distance: maxSensorDistance * sqrt(2), direction: 315)
        let seLoc = location.addVector(distance: maxSensorDistance * sqrt(2), direction: 135)

        let url = URL(string: "https://api.purpleair.com/v1/sensors?fields=latitude,longitude&location_type=0&nwlat=\(nwLoc.coordinate.latitude)&nwlng=\(nwLoc.coordinate.longitude)&selat=\(seLoc.coordinate.latitude)&selng=\(seLoc.coordinate.longitude)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchDataError.badRequest }
        guard let sensorsResp = try? JSONDecoder().decode(PurpleAirSensorsResp.self, from: data) else { throw FetchDataError.badJSON }
        let sensors = sensorsResp.data

        var potentialSensorsWithDist = [(Double, PurpleAirSensor)]()
        for sensor in sensors {
            let sensorLocation = CLLocation(latitude: sensor.latitude, longitude: sensor.longitude)
            let dist = location.distance(from: sensorLocation)
            if dist <= maxSensorDistance {
                potentialSensorsWithDist.append((dist, sensor))
            }
        }

        let sortedPotentialSensorsWithDist = potentialSensorsWithDist.sorted { $0.0 < $1.0 }
        let acceptedSensorsWithDist = sortedPotentialSensorsWithDist[0 ..< min(maxNumSensors, sortedPotentialSensorsWithDist.count)]
        let acceptedSensors = acceptedSensorsWithDist.map { $0.1 }
        return acceptedSensors
    }

    func fetchData(apiKey: String, sensors: [PurpleAirSensor], numSecondsAgo: Double) async throws -> [PurpleAirData] {
        let endIntervalDate = Date()
        let startIntervalDate = endIntervalDate.addingTimeInterval(-numSecondsAgo)
        let formatter = ISO8601DateFormatter()

        let startTime = formatter.string(from: startIntervalDate)
        let endTime = formatter.string(from: endIntervalDate)

        if sensors.count == 0 {
            throw FetchDataError.noSensors
        }

        var sensorsData: [[PurpleAirData]] = []

        for sensor in sensors {
            let url = URL(string: "https://api.purpleair.com/v1/sensors/\(sensor.index)/history?start_timestamp=\(startTime)&end_timestamp=\(endTime)&fields=temperature,humidity")!

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            guard let (data, response) = try? await URLSession.shared.data(for: request) else { throw FetchDataError.badRequest }
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchDataError.badResponse }
            guard let sensorResp = try? JSONDecoder().decode(PurpleAirSensorHistoryResp.self, from: data) else { throw FetchDataError.badJSON }
            let sensorData = sensorResp.data
            // data may be unsorted
            let sortedSensorData = sensorData.sorted { $0.date < $1.date }
            sensorsData.append(sortedSensorData)
        }

        var result = sensorsData[0]
        var numDatapoints = [Int](repeating: 1, count: result.count)

        for sensorData in sensorsData[1 ..< sensorsData.endIndex] {
            for (index, item) in sensorData.enumerated() {
                do {
                    try result[index] = result[index] + item
                    numDatapoints[index] += 1
                } catch {} // move on
            }
        }

        for index in result.indices {
            do {
                result[index] = try result[index] / Double(numDatapoints[index])
            } catch {} // move on
        }

        return result
    }

    func safeDoubleToInt(_ value: Double) -> Int {
        if value.isNaN || value.isInfinite {
            return 0
        }
        return Int(value)
    }

    func updateCollections(purpleAirData: [PurpleAirData]) {
        temp.dataPointCollection.reset()
        humidity.dataPointCollection.reset()

        for data in purpleAirData {
            temp.dataPointCollection.data.append(DataPoint(date: data.date, observation: safeDoubleToInt(data.temperature ?? 0.0), id: data.id))
            humidity.dataPointCollection.data.append(DataPoint(date: data.date, observation: safeDoubleToInt(data.humidity ?? 0.0), id: data.id))
        }

        temp.refreshMetrics()
        humidity.refreshMetrics()
    }

    func getLast60Mins() async throws {
        loading = true

        let location = CLLocation(latitude: 44.05793290200645, longitude: -121.27677774528141)
        let maxNumSensors = 1
        let maxSensorDistance: Double = 50000 // in m

        var apiKey = ""
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
           let key = config["PURPLE_AIR_API_KEY"] as? String
        {
            apiKey = key
            print("Purple Air API Key: \(apiKey)")
        }

        var purpleAirData: [PurpleAirData] = []
        do {
            let sensors = [PurpleAirSensor(index: 2661, latitude: 0.0, longitude: 0.0)] // try await identifySensors(apiKey: apiKey, location: location, maxNumSensors: maxNumSensors, maxSensorDistance: maxSensorDistance)
            purpleAirData = try await fetchData(apiKey: apiKey, sensors: sensors, numSecondsAgo: 3600)
        } catch {
            throw error
        }

        updateCollections(purpleAirData: purpleAirData)

        loading = false
    }
}
