//
//  OpenWeatherMapWeather.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation
import WeatherKit

struct OpenWeatherMapWeather: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case timezone
        case timezoneOffset = "timezone_offset"
        case currentWeather = "current"
        case minutelyForecast = "minutely"
        case hourlyForecast = "hourly"
        case dailyForecast = "daily"
        case alerts
    }
    
    let longitude: Double
    let latitude: Double
    let timezone: String
    let timezoneOffset: Int
    let currentWeather: WeatherForecast
    let minutelyForecast: [Precipitation]?
    let hourlyForecast: [WeatherForecast]
    let dailyForecast: [WeatherForecast]
    let alerts: [Alert]?
}

// MARK: - WeatherProtocol Conformance 😮‍💨
extension OpenWeatherMapWeather: TimeZoneWeatherProtocol {
    var temperature: Measurement<UnitTemperature> {
        switch currentWeather.temperature {
            case .first(let temperature):
                return temperature
            case .second(_):
                fatalError("We should not be getting the non-current weather case here")
        }
    }
    
    var apparentTemperature: Measurement<UnitTemperature> {
        switch currentWeather.feelsLike {
            case .first(let temperature):
                return temperature
            case .second(_):
                fatalError("We should not be getting the non-current weather case here")
        }
    }
    
    var minimumTemperature: Measurement<UnitTemperature> {
        guard let temperature = dailyForecast.first?.temperature else {
            fatalError("Daily weather missing for OpenWeatherMap")
        }
        switch temperature {
            case .first(_):
                fatalError("We should not be getting the non-daily weather case here")
            case .second(let temperature):
                guard let minimum = temperature.minimum else {
                    fatalError("Minimum temperature missing for daily weather")
                }
                return minimum
        }
    }
    
    var maximumTemperature: Measurement<UnitTemperature> {
        guard let temperature = dailyForecast.first?.temperature else {
            fatalError("Daily weather missing for OpenWeatherMap")
        }
        switch temperature {
            case .first(_):
                fatalError("We should not be getting the non-daily weather case here")
            case .second(let temperature):
                guard let maximum = temperature.maximum else {
                    fatalError("Maximum temperature missing for daily weather")
                }
                return maximum
        }
    }
    
    var humidity: Double {
        guard let humidity = currentWeather.humidity else {
            fatalError("Humidity missing for OpenWeatherMap")
        }
        return humidity
    }
    
    var windSpeed: Measurement<UnitSpeed> {
        guard let windSpeed = currentWeather.windSpeed else {
            fatalError("Wind speed missing for OpenWeatherMap")
        }
        return windSpeed
    }
    
    var windDirection: Measurement<UnitAngle> {
        guard let windDirection = currentWeather.windDirection else {
            fatalError("Wind direction missing for OpenWeatherMap")
        }
        return windDirection
    }
    
    var sunrise: Date? {
        today()?.sunrise
    }
    
    var sunset: Date? {
        today()?.sunset
    }
    
    var civilDawn: Date? {
        nil
    }
    
    var civilDusk: Date? {
        nil
    }
    
    var moonrise: Date? {
        today()?.moonrise
    }
    
    var nextDayMoonset: Date? {
        tomorrow()?.moonset
    }
    
    var moonPhase: MoonPhase? {
        guard let moonPhase = tomorrow()?.moonPhase else {
            return nil
        }
        
        switch moonPhase {
            case 0, 1:
                return .new
            case 0.25:
                return .firstQuarter
            case 0.5:
                return .full
            case 0.75:
                return .lastQuarter
            case let x where x > 0 && x < 0.25:
                return .waxingCrescent
            case let x where x > 0.25 && x < 0.5:
                return .waxingGibbous
            case let x where x > 0.5 && x < 0.75:
                return .waningGibbous
            case let x where x > 0.75 && x < 1:
                return .waningCrescent
            default:
                fatalError("Not within the given list of values for moon phase by OpenWeatherMaps")
        }
    }
    
    var cloudPercentage: Double {
        currentWeather.clouds
    }
    
    var symbol: String {
        currentWeather.getSymbol()
    }
    
    var condition: String {
        currentWeather.weather.first?.title.capitalized ?? ""
    }
    
    var summary: String {
        currentWeather.weather.first?.description.capitalized ?? ""
    }
    
    var uvInfo: (index: Either<Int, Double>, category: String)? {
        guard let index = currentWeather.uvIndex, let category = UVIndex.ExposureCategory.allCases.first(where: { $0.rangeValue.contains(Int(index)) }) else {
            return nil
        }
        return (.second(index), category.description)
    }
    
    var visibility: Measurement<UnitLength>? {
        currentWeather.visibility
    }
    
    var windGust: Measurement<UnitSpeed>? {
        currentWeather.windGust
    }
    
    var windCompassDirection: Wind.CompassDirection? {
        compassDirection(from: windDirection.value)
    }
    
    var pressure: Measurement<UnitPressure>? {
        currentWeather.pressure
    }
    
    var pressureTrend: PressureTrend? {
        nil
    }
    
    var precipitation: Measurement<UnitLength>? {
        today()?.rain ?? .init(value: 0, unit: .millimeters)
    }
    
    var precipitationChance: Double? {
        today()?.probabilityOfPrecipitation
    }
    
    var precipitationIntensity: Measurement<UnitSpeed>? {
        nil
    }
    
    var dewPoint: Measurement<UnitTemperature>? {
        currentWeather.dewPoint
    }
    
    var nextDaySunrise: Date? {
        tomorrow()?.sunrise
    }
    
    var nextDaySunset: Date? {
        tomorrow()?.sunset
    }
    
    var hourlyItems: [HourlyItemConvertible]? {
        hourlyForecast
    }
    
    var originalTimeZone: TimeZone {
        .autoupdatingCurrent
    }
    
    func getCelestialBodyProgress(start: Date?, end: Date?, in timeZone: TimeZone?) -> Double {
        guard let timeZone, let start = start?.from(timeZone: originalTimeZone, to: timeZone).timeIntervalSince1970, let end = end?.from(timeZone: originalTimeZone, to: timeZone).timeIntervalSince1970 else {
            return 0
        }
        
        let now = Date.now.in(timeZone: timeZone).timeIntervalSince1970
        return min(1, max(0, (now - start) / (end - start)))
    }
}

extension OpenWeatherMapWeather {
    func timeZone() -> TimeZone? {
        TimeZone(secondsFromGMT: timezoneOffset) ?? TimeZone(identifier: timezone)
    }
    
    func today() -> WeatherForecast? {
        dailyForecast.first { forecast in
            guard let date = getDate(from: forecast.unixTime) else {
                return false
            }
            return Calendar.autoupdatingCurrent.isDateInToday(date)
        }
    }
    
    func tomorrow() -> WeatherForecast? {
        dailyForecast.first { forecast in
            guard let date = getDate(from: forecast.unixTime) else {
                return false
            }
            return Calendar.autoupdatingCurrent.isDateInTomorrow(date)
        }
    }
    
    func thisHour() -> WeatherForecast? {
        hourlyForecast.first { forecast in
            guard let date = getDate(from: forecast.unixTime) else {
                return false
            }
            return Calendar.autoupdatingCurrent.isDate(date, equalTo: .now.in(timeZone: timeZone()), toGranularity: .hour)
        }
    }
    
    func nextHour() -> WeatherForecast? {
        guard let thisHour = thisHour(), let index = hourlyForecast.firstIndex(where: { thisHour.unixTime.isEqual(to: $0.unixTime) }), index != hourlyForecast.endIndex else {
            return nil
        }
        let nextIndex = hourlyForecast.index(after: index)
        return hourlyForecast[nextIndex]
    }
    
    func getDate(from seconds: TimeInterval) -> Date? {
        guard let timeZone = timeZone() else {
            return nil
        }
        
        return Date.init(timeIntervalSince1970: seconds).from(timeZone: originalTimeZone, to: timeZone)
    }
}
