import Charts
import Foundation
import SwiftUI

struct DataChartView: View {
    @Binding var sequenceData: [SensorDataPoint]
    @Binding var loading: Bool

    var body: some View {
        let maxValue = sequenceData.max { a, b in a.observation < b.observation }

        let gradient = AqiStopRange().getGradient(maxValue: maxValue?.observation ?? 0)

//        let prevColor = Color(hue: 0.69, saturation: 0.19, brightness: 0.79)
//        let curColor = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
//        let curGradient = LinearGradient(
//            gradient: Gradient(0
//                colors: [
//                    curColor.opacity(0.5),
//                    curColor.opacity(0.2),
//                    curColor.opacity(0.05),
//                ]
//
//            ),
//            startPoint: .top,
//            endPoint: .bottom
//        )

        if loading {
            ProgressView().progressViewStyle(.circular).frame(height: 300)
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
            }.frame(height: 300)

//            BarMark(
//                x: .value("Time", $0.date ..< $0.date.advanced(by: 60)),
//                y: .value("AQI", $0.aqi ?? 0)
//            )
//            .foregroundStyle(.green)
        }
//        .chartXAxis {c
//            AxisMarks(preset: .aligned, position: .bottom) { _ in
//                AxisValueLabel()
//                AxisGridLine()
//            }
//        }
    }
}
