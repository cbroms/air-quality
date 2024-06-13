import Foundation
import SwiftUI

@main
struct AirQualityApp: App {
    @StateObject private var fetcher = SensorDataFetcher()

    var body: some Scene {
        WindowGroup {
            AllDataChartsView().environmentObject(fetcher)
        }
    }
}
