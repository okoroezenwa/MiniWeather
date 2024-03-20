//
//  MockWeather.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 04/03/2024.
//

import Foundation
@testable import MiniWeather
import WeatherKit

struct MockWeather: TimeZoneWeatherProtocol, Codable {
    var hourlyItems: [any MiniWeather.HourlyItemConvertible]? { [] }
    
    var temperature: Measurement<UnitTemperature> = .init(value: 12, unit: .celsius)
    var apparentTemperature: Measurement<UnitTemperature> = .init(value: 11, unit: .celsius)
    var minimumTemperature: Measurement<UnitTemperature> = .init(value: 9, unit: .celsius)
    var maximumTemperature: Measurement<UnitTemperature> = .init(value: 12, unit: .celsius)
    var humidity: Double = 10
    var windSpeed: Measurement<UnitSpeed> = .init(value: 2, unit: .kilometersPerHour)
    var windDirection: Measurement<UnitAngle> = .init(value: 20, unit: .degrees)
    var windGust: Measurement<UnitSpeed>? = .init(value: 10, unit: .kilometersPerHour)
    var windCompassDirection: Wind.CompassDirection? = .southSouthwest
    var sunrise: Date? = Calendar.current.date(bySettingHour: 6, minute: 14, second: 30, of: .now)
    var sunset: Date? = Calendar.current.date(bySettingHour: 18, minute: 30, second: 12, of: .now)
    var nextDaySunrise: Date? = Calendar.current.date(bySettingHour: 6, minute: 14, second: 30, of: .now)
    var nextDaySunset: Date? = Calendar.current.date(bySettingHour: 18, minute: 30, second: 12, of: .now)
    var civilDawn: Date? = .now
    var civilDusk: Date? = .now
    var moonrise: Date? = .now
    var nextDayMoonset: Date? = .now
    var moonPhase: MoonPhase? = .waningGibbous
    var cloudPercentage: Double = 0.12
    var symbol: String = "cloud"
    var condition: String = "Cloudy"
    var summary: String = "Things are cloudy right now."
    var uvInfo: (index: Either<Int, Double>, category: String)? { (.first(20), "Very High") }
    var visibility: Measurement<UnitLength>? = .init(value: 10, unit: .kilometers)
    var pressure: Measurement<UnitPressure>? = .init(value: 1, unit: .bars)
    var pressureTrend: PressureTrend? { .falling }
    var precipitation: Measurement<UnitLength>? = .init(value: 2, unit: .millimeters)
    var precipitationChance: Double? = 12
    var precipitationIntensity: Measurement<UnitSpeed>? = .init(value: 2, unit: .metersPerSecond)
    var dewPoint: Measurement<UnitTemperature>? = .init(value: 0, unit: .celsius)
    var originalTimeZone: TimeZone = .current
    var timezone: String = ""
    var timezoneOffset: Int = 3600
    
    func getCelestialBodyProgress(start: Date?, end: Date?, in timeZone: TimeZone?) -> Double {
        return 0.1
    }
}
