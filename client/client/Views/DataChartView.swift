import Charts
import Foundation
import SwiftUI

struct DataChartView: View {
    @Binding var sequenceData: [SensorDataPoint]
    @Binding var loading: Bool
    @State var gradientRange: GradientRange

    var body: some View {
        let maxValue = sequenceData.max { a, b in a.observation < b.observation }
        let gradient = gradientRange.getGradient(maxValue: maxValue?.observation ?? 0)

        if loading {
            ProgressView().progressViewStyle(.circular).frame(height: 62)
        }
        else {
            Chart(sequenceData) {
//                LineMark(
//                    x: .value("Time", $0.date),
//                    y: .value("AQI", $0.observation)
//                )
//                .foregroundStyle(gradient) // if we want to use a gradient here, we'd have to adjust the 0 value to be the minimum value rather than 0

                AreaMark(
                    x: .value("Time", $0.date),
                    y: .value("AQI", $0.observation)
                )
                .foregroundStyle(gradient)
            }.frame(height: 62)
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
        }
    }
}
