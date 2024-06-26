import Foundation
import SwiftUI

struct AllDataChartsView: View, Sendable {
    @EnvironmentObject var fetcher: SensorDataFetcher

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // AQI
                Text("Air quality index")
                    .font(.largeTitle)
                    .fontDesign(.default)
                    .fontWeight(.bold)
                VStack {
                    DataChartView(sequenceData: $fetcher.aqiData, loading: $fetcher.loading)
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 6))
                Spacer()
                // temp
                Text("Temperature")
                    .font(.largeTitle)
                    .fontDesign(.default)
                    .fontWeight(.bold)
                VStack {
                    DataChartView(sequenceData: $fetcher.tempData, loading: $fetcher.loading)
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 6))
                Spacer()
                // co2
                Text("CO₂")
                    .font(.largeTitle)
                    .fontDesign(.default)
                    .fontWeight(.bold)
                VStack {
                    DataChartView(sequenceData: $fetcher.co2Data, loading: $fetcher.loading)
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 6))
                Spacer()
                // humidity
                Text("Humidity")
                    .font(.largeTitle)
                    .fontDesign(.default)
                    .fontWeight(.bold)
                VStack {
                    DataChartView(sequenceData: $fetcher.humidityData, loading: $fetcher.loading)
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 6))
                Spacer()
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
    AllDataChartsView().environmentObject(SensorDataFetcher())
}
