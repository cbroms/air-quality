import Foundation
import SwiftUI

struct AllDataChartsViewSmall: View, Sendable {
    @EnvironmentObject var sensorDataController: SensorDataController

    var body: some View {
        HStack {
            Text("Home").titleStyle()
            Spacer()
            Text("Bend, OR").labelStyle()
        }.padding(.horizontal)
        List {
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.aqi,
                loading: $sensorDataController.loading,
                metricName: "US AQI"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.co2,
                loading: $sensorDataController.loading,
                metricName: "CO₂",
                metricMeasurementType: "ppm"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.tvoc,
                loading: $sensorDataController.loading,
                metricName: "TVOC",
                metricMeasurementType: "ppb"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.temp,
                loading: $sensorDataController.loading,
                metricName: "Temp",
                metricMeasurementType: "°F"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                sensorDataMetric: $sensorDataController.humidity,
                loading: $sensorDataController.loading,
                metricName: "Humidity",
                metricMeasurementType: "%"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }.listStyle(PlainListStyle())
            .padding(.horizontal)
            .refreshable {
                do {
                    try await sensorDataController.getLast60Mins()
                } catch {
                    print(error)
                }
            }
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
