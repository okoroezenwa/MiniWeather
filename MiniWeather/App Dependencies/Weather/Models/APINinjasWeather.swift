//
//  APINinjasWeather.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 30/10/2023.
//

import Foundation

/// The API-Ninjas weather object.
struct APINinjasWeather: Decodable {
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case apparentTemperature = "feels_like"
        case minimumTemperature = "min_temp"
        case maximumTemperature = "max_temp"
        case humidity
        case windSpeed = "wind_speed"
        case windDirection = "wind_degrees"
        case sunrise = "sunrise"
        case sunset = "sunset"
        case cloudPercentage = "cloud_pct"
    }
    
    let temperature: Measurement<UnitTemperature>
    let apparentTemperature: Measurement<UnitTemperature>
    let minimumTemperature: Measurement<UnitTemperature>
    let maximumTemperature: Measurement<UnitTemperature>
    let humidity: Double
    let windSpeed: Measurement<UnitSpeed>
    let windDirection: Measurement<UnitAngle>
    let sunrise: Date?
    let sunset: Date?
    let cloudPercentage: Double
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let temp = try container.decode(Double.self, forKey: .temperature)
        self.temperature = Measurement(value: temp, unit: .celsius)
        
        let feelsLike = try container.decode(Double.self, forKey: .apparentTemperature)
        self.apparentTemperature = Measurement(value: feelsLike, unit: .celsius)
        
        let minTemp = try container.decode(Double.self, forKey: .minimumTemperature)
        self.minimumTemperature = Measurement(value: minTemp, unit: .celsius)
        
        let maxTemp = try container.decode(Double.self, forKey: .maximumTemperature)
        self.maximumTemperature = Measurement(value: maxTemp, unit: .celsius)
        
        self.humidity = try container.decode(Double.self, forKey: .humidity)
        
        let windSpeed = try container.decode(Double.self, forKey: .windSpeed)
        self.windSpeed = Measurement(value: windSpeed, unit: .metersPerSecond)
        
        let windDirection = try container.decode(Double.self, forKey: .windDirection)
        self.windDirection = Measurement(value: windDirection, unit: .degrees)
        
        let sunriseTime = try container.decode(TimeInterval.self, forKey: .sunrise)
        self.sunrise = Date(timeIntervalSince1970: sunriseTime)
        
        let sunsetTime = try container.decode(TimeInterval.self, forKey: .sunset)
        self.sunset = Date(timeIntervalSince1970: sunsetTime)
        
        self.cloudPercentage = try container.decode(Double.self, forKey: .cloudPercentage)
    }
    
    init(temperature: Measurement<UnitTemperature>, apparentTemperature: Measurement<UnitTemperature>, minimumTemperature: Measurement<UnitTemperature>, maximumTemperature: Measurement<UnitTemperature>, humidity: Double, windSpeed: Measurement<UnitSpeed>, windDirection: Measurement<UnitAngle>, sunrise: Date? = nil, sunset: Date? = nil, cloudPercentage: Double) {
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.minimumTemperature = minimumTemperature
        self.maximumTemperature = maximumTemperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.sunrise = sunrise
        self.sunset = sunset
        self.cloudPercentage = cloudPercentage
    }
}

extension APINinjasWeather: WeatherProtocol {
    var symbol: String {
        "cloud"
    }
    
    var condition: String {
        "Unknown"
    }
    
    var summary: String {
        "API-Ninjas does not return a summary."
    }
}
