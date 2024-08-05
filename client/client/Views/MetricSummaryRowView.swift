import Foundation
import SwiftUI

struct MetricSummaryRowView: View {
    @Binding var dataMetric: DataMetric
    @Binding var loading: Bool
    @State var metricName: String
    @State var metricMeasurementType: String?

    var body: some View {
        VStack(alignment: .leading) {
            HStack(content: {
                Text(metricName).headerStyle()
                if let metricMeasurementType = metricMeasurementType {
                    Text("(\(metricMeasurementType))").subHeaderStyle()
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(UIColor.systemGray3))
                    .padding(.vertical)
            })
            HStack(content: {
                DataChartView(
                    dataPointCollection: $dataMetric.dataPointCollection,
                    loading: $loading,
                    lineLinearGradient: $dataMetric.gradient.linearGradientMinToMax,
                    backgroundLinearGradient: $dataMetric.gradient.linearGradientZeroToMax
                ).padding(.trailing)

                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("NOW").labelStyle()
                        if dataMetric.latestMetric?.annotation != nil {
                            Text(dataMetric.latestMetric?.annotation ?? "").tagStyle(color: dataMetric.latestMetric?.annotationColor ?? Color(UIColor.gray))
                        }
                    }
                    Text("\(dataMetric.latestMetric?.value ?? 0)").bigNumberStyle()

                }.padding(.trailing)
                VStack(alignment: .leading) {
                    HStack {
                        Text("1HR").labelStyle()
                        if dataMetric.last60MinMetric?.annotation != nil {
                            Text(dataMetric.last60MinMetric?.annotation ?? "").tagStyle(color: dataMetric.last60MinMetric?.annotationColor ?? Color(UIColor.gray))
                        }
                    }
                    Text("\(dataMetric.last60MinMetric?.value ?? 0)").bigNumberStyle()
                }
            })
        }
    }
}
