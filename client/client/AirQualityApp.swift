import BackgroundTasks
import Foundation
import SwiftUI

@main
struct AirQualityApp: App {
    @Environment(\.scenePhase) private var phase
    @StateObject private var sensorDataController = SensorDataController()

    var body: some Scene {
        WindowGroup {
            AllDataChartsViewSmall().environmentObject(sensorDataController)
        }
        .onChange(of: phase, initial: false) {
            switch phase {
            case .background: scheduleBackgroundRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("com.rainflame.air-quality-client.refresh")) {
            scheduleBackgroundRefresh()
            do {
                try await sensorDataController.getLast60Mins()
            } catch {
                print(error)
            }
        }
    }
}

func scheduleBackgroundRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.rainflame.air-quality-client.refresh")
    request.earliestBeginDate = .now.addingTimeInterval(15 * 60) // 15 min from now
    do {
        try BGTaskScheduler.shared.submit(request)
    } catch BGTaskScheduler.Error.notPermitted {
        print("Unable to schedule task: not permitted")
    } catch BGTaskScheduler.Error.tooManyPendingTaskRequests {
        print("Unable to schedule task: too many pending task requests")
    } catch BGTaskScheduler.Error.unavailable {
        print("Unable to schedule task: unavailable")
    } catch {
        print("Unable to schedule task: \(error)")
    }
}
