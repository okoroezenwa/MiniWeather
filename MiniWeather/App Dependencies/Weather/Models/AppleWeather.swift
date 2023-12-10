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
    var temperature: Int {
        Int(currentWeather.temperature.converted(to: .celsius).value)
    }
    
    var feelsLike: Int {
        Int(currentWeather.apparentTemperature.converted(to: .celsius).value)
    }
    
    var minimumTemperature: Int {
        Int(dailyForecast.first?.lowTemperature.converted(to: .celsius).value ?? 0)
    }
    
    var maximumTemperature: Int {
        Int(dailyForecast.first?.highTemperature.converted(to: .celsius).value ?? 0)
    }
    
    var humidity: Double {
        currentWeather.humidity
    }
    
    var windSpeed: Double {
        currentWeather.wind.speed.converted(to: .kilometersPerHour).value
    }
    
    var windDegrees: Double {
        currentWeather.wind.direction.converted(to: .degrees).value
    }
    
    var sunrise: Int {
        guard let sunrise = dailyForecast.first?.sun.sunrise else {
            return 0
        }
        
        return Int(sunrise.timeIntervalSince1970)
    }
    
    var sunset: Int {
        guard let sunrise = dailyForecast.first?.sun.sunset else {
            return 0
        }
        
        return Int(sunrise.timeIntervalSince1970)
    }
    
    var cloudPercentage: Int {
        Int(currentWeather.cloudCover * 100)
    }
}
