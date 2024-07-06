import Foundation
import SwiftUI

struct AllDataChartsViewSmall: View, Sendable {
    @EnvironmentObject var fetcher: SensorDataFetcher

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // AQI
                HStack(content: {
                    Text("US AQI").headerStyle()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.vertical)
                })
                HStack(content: {
                    DataChartView(sequenceData: $fetcher.aqiData, loading: $fetcher.loading, gradientRange: AqiGradientRange())
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Text("NOW").labelStyle()
                            Text("LO").tagStyle(color: Color(UIColor.systemGreen))
                        }
                        Text("\(fetcher.aqiData.last?.observation ?? 0)").bigNumberStyle()
                    }.padding(.horizontal)
                })
            }
        }
        .padding()
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
    AllDataChartsViewSmall().environmentObject(SensorDataFetcher())
}
