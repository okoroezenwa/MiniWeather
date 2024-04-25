//
//  Settings.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 11/12/2023.
//

import Foundation

struct Settings {
    static let appTheme = "appTheme"
    static let unitsOfMeasure = "unitsOfMeasure"
    static let geocoderService = "geocoderService"
    static let weatherProvider = "weatherProvider"
    static let apiNinjasKey = "apiNinjasKey"
    static let openWeatherMapKey = "openWeatherMapKey"
    static let showLocationsUnits = "showLocationsUnits"
    static let showWeatherViewMap = "showWeatherViewMap"
    static let showWeatherViewUnits = "showWeatherViewUnits"
    static let swipeStyle = "swipeStyle"
    static let maxLocations = "maxLocations"
    
    /// The current value of the given settings key.
    static func currentValue<Value: DefaultPresenting & RawRepresentable<String>>(for key: String) -> Value {
        guard let rawValue = UserDefaults.standard.string(forKey: key), let value = Value(rawValue: rawValue) else {
            return Value.default
        }
        return value
    }
}

/// An object that has a default value to start with.
protocol DefaultPresenting {
    static var `default`: Self { get }
}

/// A type of setting where one out of multiple options can be selected.
protocol PickableSetting: DefaultPresenting, CaseIterable, Identifiable, RawRepresentable<String> { }

enum Theme: String, PickableSetting {
    case light = "Light"
    case dark = "Dark"
    case system = "Default"
    
    var id: Self {
        self
    }
    
    static let `default`: Theme = .system
}

enum Service: String, PickableSetting {
    case apple = "Apple"
    case apiNinjas = "API-Ninjas"
    case openWeatherMap = "OpenWeatherMap"
    
    var id: Self {
        self
    }
    
    static let `default`: Service = .apple
}

enum UnitOfMeasure: String, PickableSetting {
    case metric = "Metric"
    case imperial = "Imperial"
    case scientific = "Scientific"
    
    var id: Self {
        self
    }
    
    static let `default`: UnitOfMeasure = .metric
}

enum SwipeStyle: String, PickableSetting {
    case filled = "Filled"
    case rounded = "Rounded"
    case translucent = "Translucent"
    
    var id: Self {
        self
    }
    
    static let `default`: SwipeStyle = .translucent
    
    var current: some SwipeActionStyle {
        switch self {
            case .filled:
                AnySwipeActionStyle(style: .filled)
            case .rounded:
                AnySwipeActionStyle(style: .rounded)
            case .translucent:
                AnySwipeActionStyle(style: .translucentRounded)
        }
    }
}

struct LocationsCount {
    static let max = 10
}
