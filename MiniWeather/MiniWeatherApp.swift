//
//  MiniWeatherApp.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import SwiftUI

@main
struct MiniWeatherApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "H:mm a"
        
        return formatter
    }()
    
    init() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: .shared
            )
            .environment(\.timeFormatter, timeFormatter)
            .tint(.primary)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if oldValue == .background {
                NSUbiquitousKeyValueStore.default.synchronize()
            }
        }
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
