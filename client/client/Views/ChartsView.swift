import Foundation
import SwiftUI

struct ChartsView: View, Sendable {
    @EnvironmentObject var fetcher: SensorDataFetcher

    var body: some View {
        VStack {
            Text("hello this is some text")
            Divider()
            ForEach(fetcher.sensorData) { update in
                Text("\(update.aqi ?? 0)")
            }
        }
        .task {
            do {
                try await fetcher.getLast60Mins()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ChartsView().environmentObject(SensorDataFetcher())
}
