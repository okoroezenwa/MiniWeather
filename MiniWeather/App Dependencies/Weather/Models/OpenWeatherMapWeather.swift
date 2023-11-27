//
//  OpenWeatherMapWeather.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation

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
    var timezoneOffset: Int
    let currentWeather: WeatherForecast
    let minutelyForecast: [Precipitation]?
    let hourlyForecast: [WeatherForecast]
    let dailyForecast: [WeatherForecast]
    let alerts: [Alert]
}

// MARK: - WeatherProtocol Conformance 😮‍💨
extension OpenWeatherMapWeather: WeatherProtocol {
    var temperature: Int {
        switch currentWeather.temperature {
            case .first(let temperature):
                return Int(temperature)
            case .second(_):
                fatalError("We should not be getting the non-current weather case here")
        }
    }
    
    var feelsLike: Int {
        switch currentWeather.feelsLike {
            case .first(let temperature):
                return Int(temperature)
            case .second(_):
                fatalError("We should not be getting the non-current weather case here")
        }
    }
    
    var minimumTemperature: Int {
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
                return Int(minimum)
        }
    }
    
    var maximumTemperature: Int {
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
                return Int(maximum)
        }
    }
    
    var humidity: Double {
        currentWeather.humidity
    }
    
    var windSpeed: Double {
        currentWeather.windSpeed
    }
    
    var windDegrees: Double {
        currentWeather.windDirection
    }
    
    var sunrise: Int {
        guard let sunrise = currentWeather.sunrise else {
            fatalError("Sunrise info missing for current weather")
        }
        
        return sunrise
    }
    
    var sunset: Int {
        guard let sunset = currentWeather.sunset else {
            fatalError("Sunset info missing for current weather")
        }
        
        return sunset
    }
    
    var cloudPercentage: Int {
        currentWeather.clouds
    }
}
