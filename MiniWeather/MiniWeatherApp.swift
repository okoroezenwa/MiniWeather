//
//  MiniWeatherApp.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import SwiftUI

@main @MainActor
struct MiniWeatherApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(Settings.appTheme) private var theme = Theme.default
    @AppStorage(Settings.maxLocations) private var maxLocations = LocationsCount.max
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "H:mm a"
        
        return formatter
    }()
    
    let locationsViewModel = LocationsViewModel(
        userLocationAuthorisationRepositoryFactory: DependencyFactory.shared.makeUserLocationAuthorisationRepository,
        userLocationCoordinatesRepositoryFactory: DependencyFactory.shared.makeUserLocationCoordinatesRepository,
        locationsRepositoryFactory: DependencyFactory.shared.makeLocationsSearchRepository,
        weatherRepositoryFactory: DependencyFactory.shared.makeWeatherRepository,
        timeZoneRepositoryFactory: DependencyFactory.shared.makeTimeZoneRepository,
        currentLocationRepositoryFactory: DependencyFactory.shared.makeCurrentLocationRepository,
        savedLocationsRepositoryFactory: DependencyFactory.shared.makeSavedLocationsRepository
    )
    
    init() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: locationsViewModel
            )
            .environment(\.timeFormatter, timeFormatter)
            .tint(.primary)
            .preferredColorScheme(getColorScheme())
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if oldValue == .background {
                NSUbiquitousKeyValueStore.default.synchronize()
            }
        }
    }
    
    private func getColorScheme() -> ColorScheme? {
        switch theme {
            case .light: 
                return .light
            case .dark:
                return .dark
            case .system:
                return nil
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
