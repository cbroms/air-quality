import Foundation
import SwiftUI

struct MetricSummaryRowView: View {
    @Binding var sensorDataMetric: SensorDataMetric
    @Binding var loading: Bool
    @State var metricName: String
    @State var metricMeasurementType: String?

    var body: some View {
        VStack(alignment: .leading) {
            HStack(content: {
                Text(metricName).headerStyle()
                if metricMeasurementType != nil {
                    Text("(\(metricMeasurementType!))").subHeaderStyle()
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(UIColor.systemGray3))
                    .padding(.vertical)
            })
            HStack(content: {
                DataChartView(
                    dataPointCollection: $sensorDataMetric.dataPointCollection,
                    loading: $loading,
                    lineLinearGradient: $sensorDataMetric.gradient.linearGradientMinToMax,
                    backgroundLinearGradient: $sensorDataMetric.gradient.linearGradientZeroToMax
                ).padding(.trailing)

                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("NOW").labelStyle()
                        if sensorDataMetric.latestMetric?.annotation != nil {
                            Text(sensorDataMetric.latestMetric?.annotation ?? "").tagStyle(color: sensorDataMetric.latestMetric?.annotationColor ?? Color(UIColor.gray))
                        }
                    }
                    Text("\(sensorDataMetric.latestMetric?.value ?? 0)").bigNumberStyle()

                }.padding(.trailing)
                VStack(alignment: .leading) {
                    HStack {
                        Text("1HR").labelStyle()
                        if sensorDataMetric.last60MinMetric?.annotation != nil {
                            Text(sensorDataMetric.last60MinMetric?.annotation ?? "").tagStyle(color: sensorDataMetric.last60MinMetric?.annotationColor ?? Color(UIColor.gray))
                        }
                    }
                    Text("\(sensorDataMetric.last60MinMetric?.value ?? 0)").bigNumberStyle()
                }
            })
        }
    }
}
