import Foundation
import SwiftUI

struct TimeSinceLastUpdateView: View {
    @Binding var lastUpdateTime: Date?
    @State private var currentTime = Date()

    var body: some View {
        Text(timeIntervalSinceNowText).labelStyle()
            .onAppear {
                startTimer()
            }
    }

    var timeIntervalSinceNowText: String {
        if let latestUpdate = lastUpdateTime {
            let timeInterval = -latestUpdate.timeIntervalSinceNow
            return formattedTimeInterval(interval: timeInterval)
        } else {
            return ""
        }
    }

    private func formattedTimeInterval(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]

        if let formattedString = formatter.string(from: interval) {
            return "\(formattedString) ago"
        } else {
            return "Just now"
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
}
