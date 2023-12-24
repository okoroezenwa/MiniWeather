//
//  AppleWeather.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 10/12/2023.
//

import Foundation
import WeatherKit

#warning("Maybe unchecked Sendable conformance not a good idea?")
extension Weather: WeatherProtocol, @unchecked Sendable {
    var temperature: Measurement<UnitTemperature> {
        currentWeather.temperature
    }
    
    var apparentTemperature: Measurement<UnitTemperature> {
        currentWeather.apparentTemperature
    }
    
    var minimumTemperature: Measurement<UnitTemperature> {
        guard let dailyForecast = dailyForecast.first else {
            fatalError("Daily weather missing for Apple Weather")
        }
        return dailyForecast.lowTemperature
    }
    
    var maximumTemperature: Measurement<UnitTemperature> {
        guard let dailyForecast = dailyForecast.first else {
            fatalError("Daily weather missing for Apple Weather")
        }
        return dailyForecast.highTemperature
    }
    
    var humidity: Double {
        currentWeather.humidity
    }
    
    var windSpeed: Measurement<UnitSpeed> {
        currentWeather.wind.speed
    }
    
    var windDirection: Measurement<UnitAngle> {
        currentWeather.wind.direction
    }
    
    var sunrise: Date? {
        today()?.sun.sunrise
    }
    
    var sunset: Date? {
        today()?.sun.sunset
    }
    
    var cloudPercentage: Double {
        currentWeather.cloudCover * 100
    }
    
    var symbol: String {
        currentWeather.symbolName
    }
    
    var condition: String {
        currentWeather.condition.description.capitalized
    }
    
    var summary: String {
        currentWeather.condition.description
    }
    
    var civilDawn: Date? {
        today()?.sun.civilDawn
    }
    
    var civilDusk: Date? {
        today()?.sun.civilDusk
    }
    
    var moonrise: Date? {
        today()?.moon.moonrise
    }
    
    var nextDayMoonset: Date? {
        tomorrow()?.moon.moonset
    }
    
    var moonPhase: MoonPhase? {
        tomorrow()?.moon.phase
    }
    
    var uvInfo: (index: Either<Int, Double>, category: String)? {
        (.first(currentWeather.uvIndex.value), currentWeather.uvIndex.category.description)
    }
    
    var visibility: Measurement<UnitLength>? {
        currentWeather.visibility
    }
    
    var windGust: Measurement<UnitSpeed>? {
        currentWeather.wind.gust
    }
    
    var windCompassDirection: Wind.CompassDirection? {
        currentWeather.wind.compassDirection
    }
    
    var pressure: Measurement<UnitPressure>? {
        currentWeather.pressure
    }
    
    var pressureTrend: PressureTrend? {
        currentWeather.pressureTrend
    }
    
    var precipitation: Measurement<UnitLength>? {
        today()?.precipitationAmount
    }
    
    var precipitationChance: Double? {
        today()?.precipitationChance
    }
    
    var precipitationIntensity: Measurement<UnitSpeed>? {
        currentWeather.precipitationIntensity
    }
    
    var dewPoint: Measurement<UnitTemperature>? {
        currentWeather.dewPoint
    }
    
    var nextDaySunrise: Date? {
        tomorrow()?.sun.sunrise
    }
    
    var nextDaySunset: Date? {
        tomorrow()?.sun.sunset
    }
    
    var hourlyItems: [HourlyItemConvertible]? {
        hourlyForecast.forecast
    }
    
    var originalTimeZone: TimeZone {
        .autoupdatingCurrent
    }
    
    func getCelestialBodyProgress(start: Date?, end: Date?, in timeZone: TimeZone?) -> Double {
        guard let timeZone, let start = start?.in(timeZone: timeZone).timeIntervalSince1970, let end = end?.in(timeZone: timeZone).timeIntervalSince1970 else {
            return 0
        }
        
        let now = Date.now.in(timeZone: timeZone).timeIntervalSince1970
        return min(1, max(0, (now - start) / (end - start)))
    }
}
