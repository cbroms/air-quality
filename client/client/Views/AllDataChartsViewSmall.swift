import Foundation
import SwiftUI

struct AllDataChartsViewSmall: View, Sendable {
    @EnvironmentObject var sensorDataController: SensorDataController

    var body: some View {
        ScrollView {
            MetricSummaryRowView(
                sequenceData: $sensorDataController.aqiData.data,
                loading: $sensorDataController.loading,
                latestObservation: $sensorDataController.latestAqiMetric,
                gradient: $sensorDataController.aqiGradient.gradient,
                metricName: "US AQI"
            )
            MetricSummaryRowView(
                sequenceData: $sensorDataController.co2Data.data,
                loading: $sensorDataController.loading,
                latestObservation: $sensorDataController.latestCo2Metric,
                gradient: $sensorDataController.co2Gradient.gradient,
                metricName: "CO₂"
            )
            MetricSummaryRowView(
                sequenceData: $sensorDataController.tempData.data,
                loading: $sensorDataController.loading,
                latestObservation: $sensorDataController.latestTempMetric,
                gradient: $sensorDataController.tempGradient.gradient,
                metricName: "Temperature"
            )
            MetricSummaryRowView(
                sequenceData: $sensorDataController.humidityData.data,
                loading: $sensorDataController.loading,
                latestObservation: $sensorDataController.latestHumidityMetric,
                gradient: $sensorDataController.humidityGradient.gradient,
                metricName: "Humidity"
            )
        }
        .padding()
        .task {
            do {
                try await sensorDataController.getLast60Mins()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    AllDataChartsViewSmall().environmentObject(SensorDataController())
}
