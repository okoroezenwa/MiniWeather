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
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "H:mm a"
        
        return formatter
    }()
    /// The location being searched for. This _should_ be in LocationsView but the searchable-related environment values are structured weirdly and this was much easier than changing my view heirarchy a lot.
    @State private var searchText = ""

    var body: some Scene {
        WindowGroup {
            LocationsView(
                viewModel: .shared,
                searchText: $searchText
            )
            .environment(\.timeFormatter, timeFormatter)
            .tint(.primary)
            .searchable(text: $searchText, prompt: "Search City Name")
        }
        .modelContainer(sharedModelContainer)
    }
}


private struct TimeFormatterKey: EnvironmentKey {
    static let defaultValue: DateFormatter = DateFormatter()
}

extension EnvironmentValues {
    var timeFormatter: DateFormatter {
        get { self[TimeFormatterKey.self] }
        set { self[TimeFormatterKey.self] = newValue }
    }
}
