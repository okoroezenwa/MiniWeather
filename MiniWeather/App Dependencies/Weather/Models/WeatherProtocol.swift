//
//  WeatherProtocol.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation

protocol WeatherProtocol: Sendable {
    var temperature: Int { get }
    var feelsLike: Int { get }
    var minimumTemperature: Int { get }
    var maximumTemperature: Int { get }
    var humidity: Double { get }
    var windSpeed: Double { get }
    var windDegrees: Double { get }
    var sunrise: Int { get }
    var sunset: Int { get }
    var cloudPercentage: Int { get }
}

extension WeatherProtocol {
    func tempString() -> String {
        temperature.formatted(.number) + preferredTemperatureSymbol()
    }
    
    func minTempString() -> String {
        String(minimumTemperature)
    }
    
    func maxTempString() -> String {
        String(maximumTemperature)
    }
    
    func getMinMaxTempString() -> String {
        "H \(maximumTemperature)\(preferredTemperatureSymbol()) • L \(minimumTemperature)\(preferredTemperatureSymbol())"
    }
}

// MARK: - Preferred Units
extension WeatherProtocol {
    func currentUnitsPreference() -> UnitOfMeasure {
        Settings.currentValue(for: Settings.unitsOfMeasure)
    }
    
    func preferredTemperatureUnit() -> UnitTemperature {
        switch currentUnitsPreference() {
            case .metric:
                return .celsius
            case .imperial:
                return .fahrenheit
            case .scientific:
                return .kelvin
        }
    }
    
    func preferredTemperatureSymbol() -> String {
        switch currentUnitsPreference() {
            case .metric, .imperial:
                return "°"
            case .scientific:
                return ""
        }
    }
    
    func preferredSpeedUnit() -> UnitSpeed {
        switch currentUnitsPreference() {
            case .metric, .scientific:
                return .metersPerSecond
            case .imperial:
                return .milesPerHour
        }
    }
    
    func preferredAngleUnit() -> UnitAngle {
        .degrees
    }
    
    func preferredStandardDistanceUnit() -> UnitLength {
        switch currentUnitsPreference() {
            case .metric, .scientific:
                return .meters
            case .imperial:
                return .feet
        }
    }
    
    func preferredMinorDistanceUnit() -> UnitLength {
        switch currentUnitsPreference() {
            case .metric, .scientific:
                return .millimeters
            case .imperial:
                return .inches
        }
    }
    
    func preferredPressureUnit() -> UnitPressure {
        switch currentUnitsPreference() {
            case .metric, .scientific:
                return .hectopascals
            case .imperial:
                return .poundsForcePerSquareInch
        }
    }
}
