struct DataPointCollection {
    var data: [DataPoint] = []

    func getMax() -> Int {
        return data.max { a, b in a.observation < b.observation }?.observation ?? 0
    }

    func getMin() -> Int {
        return data.min { a, b in a.observation < b.observation }?.observation ?? 0
    }

    func getAvg() -> Int {
        let sum = data.reduce(0) { sum, a in a.observation + sum }
        if data.count == 0 {
            return 0
        }
        return sum / data.count
    }

    func getLatest() -> DataPoint? {
        return data.last
    }

    mutating func reset() {
        data.removeAll()
    }
}
