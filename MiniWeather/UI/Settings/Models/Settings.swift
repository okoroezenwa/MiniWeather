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
    static let toastStyle = "toastStyle"
    
    /// The current value of the given settings key.
    static func currentValue<Value: DefaultPresenting & RawRepresentable<String>>(for key: String) -> Value {
        guard let rawValue = UserDefaults.standard.string(forKey: key), let value = Value(rawValue: rawValue) else {
            return Value.default
        }
        return value
    }
}

enum Theme: String, PickableSetting {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    static let `default`: Theme = .system
}

enum Service: String, PickableSetting {
    case apple = "Apple"
    case apiNinjas = "API-Ninjas"
    case openWeatherMap = "OpenWeatherMap"
    
    static let `default`: Service = .apple
}

enum UnitOfMeasure: String, PickableSetting {
    case metric = "Metric"
    case imperial = "Imperial"
    case scientific = "Scientific"
    
    static let `default`: UnitOfMeasure = .metric
}

enum SwipeStyle: String, PickableSetting {
    case filled = "Filled"
    case rounded = "Rounded"
    case translucent = "Translucent"
    
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

enum MaxLocations: String, PickableSetting {
    case five = "5 Locations"
    case ten = "10 Locations"
    case fifteen = "15 Locations"
    case twenty = "20 Locations"
    
    static let `default`: MaxLocations = .ten
    
    var amount: Int {
        switch self {
            case .five:
                5
            case .ten:
                10
            case .fifteen:
                15
            case .twenty:
                20
        }
    }
}

enum ToastStyle: String, PickableSetting {
    case solid = "Solid"
    case translucent = "Translucent"
    case dolidTranslucent = "Bordered Solid"
    case borderedTranslucent = "Bordered Translucent"
    
    static let `default`: ToastStyle = .translucent
}
