import Foundation
import SwiftUI

struct MetricSummaryRowView: View {
    @Binding var sensorDataMetric: SensorDataMetric
    @Binding var loading: Bool
    @State var metricName: String
    @State var metricMeasurementType: String?

    var body: some View {
        VStack(alignment: .leading) {
            // AQI
            HStack(content: {
                Text(metricName).headerStyle()
                if metricMeasurementType != nil {
                    Text("(\(metricMeasurementType!))").subHeaderStyle()
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(UIColor.systemGray2))
                    .padding(.vertical)
            })
            HStack(content: {
                DataChartView(
                    sequenceData: $sensorDataMetric.dataPointCollection.data,
                    loading: $loading,
                    gradient: $sensorDataMetric.gradient.linearGradient)
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("NOW").labelStyle()
                        if sensorDataMetric.latestMetric?.annotation != nil {
                            Text(sensorDataMetric.latestMetric?.annotation ?? "").tagStyle(color: sensorDataMetric.latestMetric?.annotationColor ?? Color.gray)
                        }
                    }
                    Text("\(sensorDataMetric.latestMetric?.value ?? 0)").bigNumberStyle()

                }.padding(.horizontal)
            })
        }
    }
}
