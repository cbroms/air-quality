import Charts
import Foundation
import SwiftUI

struct AQIDataPoint: Identifiable {
    let id = UUID()
    let time: String
    let value: Double
}

struct DataChartView: View {
    @EnvironmentObject var fetcher: SensorDataFetcher

    var body: some View {
        Chart(fetcher.sensorData) {
            LineMark(
                x: .value("Time", $0.time),
                y: .value("AQI", $0.aqi ?? 0)
            ).foregroundStyle(Color.white)
        }
    }
}
