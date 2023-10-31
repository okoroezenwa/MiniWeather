//
//  Weather.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 30/10/2023.
//

import Foundation

struct Weather: Decodable {
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case minimumTemperature = "min_temp"
        case maximumTemperature = "max_temp"
        case humidity
        case windSpeed = "wind_speed"
        case windDegrees = "wind_degrees"
        case sunrise
        case sunset
        case cloudPercentage = "cloud_pct"
    }
    
    let temperature: Int
    let feelsLike: Int
    let minimumTemperature: Int
    let maximumTemperature: Int
    let humidity: Double
    let windSpeed: Double
    let windDegrees: Double
    let sunrise: Int
    let sunset: Int
    let cloudPercentage: Int
    
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
