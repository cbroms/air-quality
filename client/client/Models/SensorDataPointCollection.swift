struct SensorDataPointCollection {
    var data: [SensorDataPoint] = []

    func getMax() -> Int {
        return data.max { a, b in a.observation < b.observation }?.observation ?? 0
    }

    func getMin() -> Int {
        return data.min { a, b in a.observation < b.observation }?.observation ?? 0
    }

    func getAvg() -> Int {
        let sum = data.reduce(0) { sum, a in a.observation + sum }
        return sum / data.count
    }

    func getLatest() -> SensorDataPoint {
        return data.last!
    }

    mutating func reset() {
        data.removeAll()
    }
}
