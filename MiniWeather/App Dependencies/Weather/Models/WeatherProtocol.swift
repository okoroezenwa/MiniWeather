//
//  WeatherProtocol.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation
import WeatherKit

protocol WeatherProtocol: Sendable {
    var temperature: Measurement<UnitTemperature> { get }
    var apparentTemperature: Measurement<UnitTemperature> { get }
    var minimumTemperature: Measurement<UnitTemperature> { get }
    var maximumTemperature: Measurement<UnitTemperature> { get }
    var humidity: Double { get }
    var windSpeed: Measurement<UnitSpeed> { get }
    var windDirection: Measurement<UnitAngle> { get }
    var windGust: Measurement<UnitSpeed>? { get }
    var windCompassDirection: Wind.CompassDirection? { get }
    var sunrise: Date? { get }
    var sunset: Date? { get }
    var nextDaySunrise: Date? { get }
    var nextDaySunset: Date? { get }
    var civilDawn: Date? { get }
    var civilDusk: Date? { get }
    var moonrise: Date? { get }
    var nextDayMoonset: Date? { get }
    var moonPhase: MoonPhase? { get }
    var cloudPercentage: Double { get }
    var symbol: String { get }
    var condition: String { get }
    var summary: String { get }
    var uvInfo: (index: Either<Int, Double>, category: String)? { get }
    var visibility: Measurement<UnitLength>? { get }
    var pressure: Measurement<UnitPressure>? { get }
    var pressureTrend: PressureTrend? { get }
    var precipitation: Measurement<UnitLength>? { get }
    var precipitationChance: Double? { get }
    var precipitationIntensity: Measurement<UnitSpeed>? { get }
    var dewPoint: Measurement<UnitTemperature>? { get }
    var hourlyItems: [HourlyItemConvertible]? { get }
    var originalTimeZone: TimeZone { get }
    
    func getCelestialBodyProgress(start: Date?, end: Date?, in timeZone: TimeZone?) -> Double
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
    
    func compassDirection(from direction: Double) -> Wind.CompassDirection {
        switch direction {
            case 0..<22.5, 360:
                return .north
            case 22.5..<45:
                return .northNortheast
            case 45..<67.5:
                return .northeast
            case 67.5..<90:
                return .eastNortheast
            case 90..<112.5:
                return .east
            case 112.5..<135:
                return .eastSoutheast
            case 135..<157.5:
                return .southeast
            case 157.5..<180:
                return .southSoutheast
            case 180..<202.5:
                return .south
            case 202.5..<225:
                return .southSouthwest
            case 225..<247.5:
                return .southwest
            case 247.5..<270:
                return .westSouthwest
            case 270..<292.5:
                return  .west
            case 292.5..<315:
                return .westNorthwest
            case 315..<337.5:
                return .northwest
            case 337.5..<360:
                return .northNorthwest
            default:
                fatalError("Over 360 degree wind direction for OpenWeatherMap")
        }
    }
    
    func formattedUVIndex() -> String {
        guard let uvInfo else {
            return "--"
        }
        
        switch uvInfo.index {
            case .first(let value):
                return value.formatted()
            case .second(let value):
                return value.formatted(.number.precision(.fractionLength(1)))
        }
    }
    
    func getHourlyItems(in timeZone: TimeZone) -> [HourlyForecastCard.Item] {
        guard let hourlyItems, let firstIndex = hourlyItems.firstIndex(where: { Calendar.autoupdatingCurrent.isDate($0.date.from(timeZone: originalTimeZone, to: timeZone), equalTo: .now.in(timeZone: timeZone), toGranularity: .hour) }) else {
            return []
        }
        
        var items = hourlyItems[firstIndex...(firstIndex + 24)].map { $0.asItem(unit: preferredTemperatureUnit(), temperatureSymbol: preferredTemperatureSymbol(), timeZone: timeZone) }
        let itemsToAdd: [(date: Date?, imageName: String, bottomText: String)] = [
            (
                sunrise,
                "sunrise",
                "Sunrise"
            ),
            (
                sunset,
                "sunset",
                "Sunset"
            ),
            (
                nextDaySunrise,
                "sunrise",
                "Sunrise"
            ),
            (
                nextDaySunset,
                "sunset",
                "Sunset"
            )
        ]
        
        for item in itemsToAdd {
            guard let date = item.date, let index = items.firstIndex(where: { Calendar.autoupdatingCurrent.isDate(date, equalTo: $0.date, toGranularity: .hour) }) else {
                continue
            }
            let indexAfter = items.index(after: index)
            let item = HourlyForecastCard.Item(unit: preferredTemperatureUnit(), temperatureSymbol: preferredTemperatureSymbol(), imageName: item.imageName, time: date.in(timeZone: timeZone).formatted(date: .omitted, time: .shortened), temperature: item.bottomText, date: date)
            items.insert(item, at: indexAfter)
        }
        
        return items
    }
}

enum Either<First, Second> {
    case first(First)
    case second(Second)
}
