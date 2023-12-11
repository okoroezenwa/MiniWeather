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
        Int(currentWeather.temperature.converted(to: preferredTemperatureUnit()).value)
    }
    
    var feelsLike: Int {
        Int(currentWeather.apparentTemperature.converted(to: preferredTemperatureUnit()).value)
    }
    
    var minimumTemperature: Int {
        Int(dailyForecast.first?.lowTemperature.converted(to: preferredTemperatureUnit()).value ?? 0)
    }
    
    var maximumTemperature: Int {
        Int(dailyForecast.first?.highTemperature.converted(to: preferredTemperatureUnit()).value ?? 0)
    }
    
    var humidity: Double {
        currentWeather.humidity
    }
    
    var windSpeed: Double {
        currentWeather.wind.speed.converted(to: preferredSpeedUnit()).value
    }
    
    var windDegrees: Double {
        currentWeather.wind.direction.converted(to: preferredAngleUnit()).value
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
