import Foundation

struct DataMetric {
    var dataPointCollection: DataPointCollection
    var gradient: GradientManager
    var latestUpdateTime: Date?
    var latestMetric: IntermediateGradientPosition?
    var last60MinMetric: IntermediateGradientPosition?

    mutating func refreshMetrics() {
        gradient.recomputeGradients(maxValue: dataPointCollection.getMax(), minValue: dataPointCollection.getMin())
        let latest = dataPointCollection.getLatest()

        latestUpdateTime = latest?.date ?? Date()
        let observation = latest?.observation ?? 0

        latestMetric = gradient.getIntermediateGradientPositionFromValue(value: observation)
        last60MinMetric = gradient.getIntermediateGradientPositionFromValue(value: dataPointCollection.getAvg())
    }
}
