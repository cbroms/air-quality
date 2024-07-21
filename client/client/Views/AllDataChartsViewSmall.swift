import Foundation
import SwiftUI

struct AllDataChartsViewSmall: View, Sendable {
    @EnvironmentObject var sensorDataController: SensorDataController

    var body: some View {
        ScrollView {
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.aqi,
                loading: $sensorDataController.loading,
                metricName: "US AQI"
            )
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.co2,
                loading: $sensorDataController.loading,
                metricName: "CO₂",
                metricMeasurementType: "ppm"
            )
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.tvoc,
                loading: $sensorDataController.loading,
                metricName: "TVOC",
                metricMeasurementType: "ppb"
            )
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.temp,
                loading: $sensorDataController.loading,
                metricName: "Temp",
                metricMeasurementType: "°F"
            )
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.humidity,
                loading: $sensorDataController.loading,
                metricName: "Humidity",
                metricMeasurementType: "%"
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
