//
//  MiniWeatherApp.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import SwiftUI
import SwiftData

@main
struct MiniWeatherApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Location.self,
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
            LocationsView()
        }
        .modelContainer(sharedModelContainer)
    }
}
