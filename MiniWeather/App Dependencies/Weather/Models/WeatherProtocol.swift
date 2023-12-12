//
//  WeatherProtocol.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation

protocol WeatherProtocol: Sendable {
    var temperature: Measurement<UnitTemperature> { get }
    var apparentTemperature: Measurement<UnitTemperature> { get }
    var minimumTemperature: Measurement<UnitTemperature> { get }
    var maximumTemperature: Measurement<UnitTemperature> { get }
    var humidity: Double { get }
    var windSpeed: Measurement<UnitSpeed> { get }
    var windDirection: Measurement<UnitAngle> { get }
    var sunrise: Date? { get }
    var sunset: Date? { get }
    var cloudPercentage: Double { get }
    var symbol: String { get }
}

extension WeatherProtocol {
    func tempString(withUnit: Bool = false) -> String {
        Int(temperature.converted(to: preferredTemperatureUnit()).value).formatted(.number) + preferredTemperatureSymbol() + (withUnit ? preferredTemperatureUnitLetter() : "")
    }
    
    func minTempString() -> String {
        Int(minimumTemperature.converted(to: preferredTemperatureUnit()).value).formatted(.number) + preferredTemperatureSymbol()
    }
    
    func maxTempString() -> String {
        Int(maximumTemperature.converted(to: preferredTemperatureUnit()).value).formatted(.number) + preferredTemperatureSymbol()
    }
    
    func getMinMaxTempString() -> String {
        "H \(maxTempString()) • L \(minTempString())"
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
    
    func preferredTemperatureUnitLetter() -> String {
        switch currentUnitsPreference() {
            case .metric:
                return "C"
            case .imperial:
                return "F"
            case .scientific:
                return "K"
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
