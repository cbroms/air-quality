import Foundation
import SwiftUI

struct MetricSummaryRowView: View {
    @Binding var sequenceData: [SensorDataPoint]
    @Binding var loading: Bool
    @Binding var latestObservation: IntermediateGradientPosition?
    @Binding var gradient: LinearGradient?
    @State var metricName: String

    var body: some View {
        VStack(alignment: .leading) {
            // AQI
            HStack(content: {
                Text(metricName).headerStyle()
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.vertical)
            })
            HStack(content: {
                DataChartView(
                    sequenceData: $sequenceData,
                    loading: $loading,
                    gradient: $gradient)
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("NOW").labelStyle()
                        if latestObservation != nil {
                            Text(latestObservation?.annotation ?? "").tagStyle(color: latestObservation?.annotationColor ?? Color.gray)
                        }
                    }
                    Text("\(latestObservation?.value ?? 0)").bigNumberStyle()

                }.padding(.horizontal)
            })
        }
    }
}
