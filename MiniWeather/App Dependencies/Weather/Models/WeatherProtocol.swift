//
//  WeatherProtocol.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation

protocol WeatherProtocol: Sendable {
    var temperature: Int { get }
    var feelsLike: Int { get }
    var minimumTemperature: Int { get }
    var maximumTemperature: Int { get }
    var humidity: Double { get }
    var windSpeed: Double { get }
    var windDegrees: Double { get }
    var sunrise: Int { get }
    var sunset: Int { get }
    var cloudPercentage: Int { get }
}

extension WeatherProtocol {
    func tempString() -> String {
        String(temperature)
    }
    
    func minTempString() -> String {
        String(minimumTemperature)
    }
    
    func maxTempString() -> String {
        String(maximumTemperature)
    }
    
    func getMinMaxTempString() -> String {
        "H \(maximumTemperature)° • L \(minimumTemperature)°"
    }
}
