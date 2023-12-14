//
//  AppleWeather.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 10/12/2023.
//

import Foundation
import WeatherKit

#warning("Maybe not a good idea?")
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
        dailyForecast.first?.sun.sunrise
    }
    
    var sunset: Date? {
        dailyForecast.first?.sun.sunset
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
}
