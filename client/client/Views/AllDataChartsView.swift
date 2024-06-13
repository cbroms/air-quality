import Foundation
import SwiftUI

struct AllDataChartsView: View, Sendable {
    @EnvironmentObject var fetcher: SensorDataFetcher

    var body: some View {
        VStack(alignment: .leading) {
            Text("Air quality index")
                .font(.largeTitle)
                .fontDesign(.default)
                .fontWeight(.bold)
            VStack {
                DataChartView()
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 6))
            Spacer()
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
