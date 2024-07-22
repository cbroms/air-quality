import Charts
import Foundation
import SwiftUI

struct DataChartView: View {
    @Binding var sequenceData: [SensorDataPoint]
    @Binding var loading: Bool
    @Binding var lineLinearGradient: LinearGradient?
    @Binding var backgroundLinearGradient: LinearGradient?

    var body: some View {
        if loading || backgroundLinearGradient == nil {
            ProgressView().progressViewStyle(.circular).frame(height: 62)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        else {
            Chart(sequenceData) {
                AreaMark(
                    x: .value("Time", $0.date),
                    y: .value("AQI", $0.observation)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(backgroundLinearGradient!)

                LineMark(
                    x: .value("Time", $0.date),
                    y: .value("AQI", $0.observation)
                ).lineStyle(StrokeStyle(lineWidth: 2.0))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(lineLinearGradient!)
            }.frame(height: 62)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
                }
        }
    }
}
