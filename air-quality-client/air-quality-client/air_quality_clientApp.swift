//
//  air_quality_clientApp.swift
//  air-quality-client
//
//  Created by Christian Broms on 5/6/24.
//

import SwiftUI
import SwiftData

@main
struct air_quality_clientApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Sensor.self,
            SensorData.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
