import Foundation
import SwiftUI

@main
struct AirQualityApp: App {
    @StateObject private var sensorDataController = SensorDataController()

    var body: some Scene {
        WindowGroup {
            AllDataChartsViewSmall().environmentObject(sensorDataController)
        }
    }
}
