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
                metricName: "CO₂"
            )
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.temp,
                loading: $sensorDataController.loading,
                metricName: "Temperature"
            )
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.humidity,
                loading: $sensorDataController.loading,
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
