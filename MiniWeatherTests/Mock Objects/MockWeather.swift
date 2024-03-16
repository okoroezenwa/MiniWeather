//
//  MockWeather.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 04/03/2024.
//

import Foundation
@testable import MiniWeather
import WeatherKit

struct MockWeather: WeatherProtocol {
    var hourlyItems: [any MiniWeather.HourlyItemConvertible]?
    
    let temperature: Measurement<UnitTemperature> = .init(value: 12, unit: .celsius)
    let apparentTemperature: Measurement<UnitTemperature> = .init(value: 11, unit: .celsius)
    let minimumTemperature: Measurement<UnitTemperature> = .init(value: 9, unit: .celsius)
    let maximumTemperature: Measurement<UnitTemperature> = .init(value: 12, unit: .celsius)
    let humidity: Double = 10
    let windSpeed: Measurement<UnitSpeed> = .init(value: 2, unit: .kilometersPerHour)
    let windDirection: Measurement<UnitAngle> = .init(value: 20, unit: .degrees)
    let windGust: Measurement<UnitSpeed>? = .init(value: 10, unit: .kilometersPerHour)
    let windCompassDirection: Wind.CompassDirection? = .southSouthwest
    let sunrise: Date? = Calendar.current.date(bySettingHour: 6, minute: 14, second: 30, of: .now)
    let sunset: Date? = Calendar.current.date(bySettingHour: 18, minute: 30, second: 12, of: .now)
    let nextDaySunrise: Date? = Calendar.current.date(bySettingHour: 6, minute: 14, second: 30, of: .now)
    let nextDaySunset: Date? = Calendar.current.date(bySettingHour: 18, minute: 30, second: 12, of: .now)
    let civilDawn: Date? = .now
    let civilDusk: Date? = .now
    let moonrise: Date? = .now
    let nextDayMoonset: Date? = .now
    let moonPhase: MoonPhase? = .waningGibbous
    let cloudPercentage: Double
    let symbol: String = "cloud"
    let condition: String = "Cloudy"
    let summary: String = "Things are cloudy right now."
    let uvInfo: (index: Either<Int, Double>, category: String)? = (.first(20), "Very High")
    let visibility: Measurement<UnitLength>? = .init(value: 10, unit: .kilometers)
    let pressure: Measurement<UnitPressure>? = .init(value: 1, unit: .bars)
    var pressureTrend: PressureTrend? { .falling }
    let precipitation: Measurement<UnitLength>? = .init(value: 2, unit: .millimeters)
    let precipitationChance: Double? = 12
    let precipitationIntensity: Measurement<UnitSpeed>? = .init(value: 2, unit: .metersPerSecond)
    let dewPoint: Measurement<UnitTemperature>? = .init(value: 0, unit: .celsius)
    let originalTimeZone: TimeZone = .current
    
    func getCelestialBodyProgress(start: Date?, end: Date?, in timeZone: TimeZone?) -> Double {
        return 0.1
    }
}
