import Foundation
import SwiftUI

struct AllDataChartsViewSmall: View, Sendable {
    @EnvironmentObject var purpleAirDataController: PurpleAirDataController
    @EnvironmentObject var sensorDataController: SensorDataController

    var body: some View {
        HStack(alignment: .lastTextBaseline, content: {
            Text("Outside").titleStyle()
            TimeSinceLastUpdateView(lastUpdateTime: $purpleAirDataController.temp.latestUpdateTime)
            Spacer()
            Text("Bend, OR").labelStyle()
        }).padding(.horizontal)
        List {
            MetricSummaryRowView(
                dataMetric: $purpleAirDataController.temp,
                loading: $purpleAirDataController.loading,
                metricName: "Temp",
                metricMeasurementType: "°F"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                dataMetric: $purpleAirDataController.humidity,
                loading: $purpleAirDataController.loading,
                metricName: "Humidity",
                metricMeasurementType: "%"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }.listStyle(PlainListStyle())
            .padding(.horizontal)
            .refreshable {
                do {
                    try await purpleAirDataController.getLast60Mins()
                } catch {
                    print(error)
                }
            }
            .task {
                do {
                    try await purpleAirDataController.getLast60Mins()
                } catch {
                    print(error)
                }
            }

        HStack(alignment: .lastTextBaseline, content: {
            Text("Home").titleStyle()
            TimeSinceLastUpdateView(lastUpdateTime: $sensorDataController.aqi.latestUpdateTime)
            Spacer()
            Text("Bend, OR").labelStyle()
        }).padding(.horizontal)
        List {
            MetricSummaryRowView(
                dataMetric: $sensorDataController.aqi,
                loading: $sensorDataController.loading,
                metricName: "US AQI"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                dataMetric: $sensorDataController.co2,
                loading: $sensorDataController.loading,
                metricName: "CO₂",
                metricMeasurementType: "ppm"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                dataMetric: $sensorDataController.tvoc,
                loading: $sensorDataController.loading,
                metricName: "TVOC",
                metricMeasurementType: "ppb"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                dataMetric: $sensorDataController.temp,
                loading: $sensorDataController.loading,
                metricName: "Temp",
                metricMeasurementType: "°F"
            ).listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            MetricSummaryRowView(
                dataMetric: $sensorDataController.humidity,
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
    AllDataChartsViewSmall().environmentObject(PurpleAirDataController()).environmentObject(SensorDataController())
}
