//
//  OpenWeatherMapCodables.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation

struct WeatherForecast: Codable {
    let unixTime: Int
    let sunrise: Int?
    let sunset: Int?
    let moonrise: Int?
    let moonset: Int?
    let moonPhase: Double?
    let summary: String?
    let temperature: DualValueDecodable<Double, Temperature> // Daily uses Temperature, others use Double
    let feelsLike: DualValueDecodable<Double, Temperature> // Daily uses Temperature, others use Double
    let pressure: Double?
    let humidity: Double?
    let dewPoint: Double?
    let uvIndex: Double?
    let clouds: Int
    let visibility: Double?
    let windSpeed: Double?
    let windGust: Double?
    let windDirection: Double?
    let probabilityOfPrecipitation: Double?
    let rain: DualValueDecodable<Double, HourReading>? // Daily uses Double, others use HourReading
    let snow: DualValueDecodable<Double, HourReading>? // Daily uses Double, others use HourReading
    let weather: [WeatherCondition]
    
    enum CodingKeys: String, CodingKey {
        case unixTime = "dt"
        case sunrise = "sunrise"
        case sunset = "sunset"
        case moonrise
        case moonset
        case moonPhase = "moon_phase"
        case summary
        case temperature = "temp"
        case feelsLike = "feels_like"
        case pressure = "pressure"
        case humidity = "humidity"
        case dewPoint = "dew_point"
        case clouds = "clouds"
        case uvIndex = "uvi"
        case visibility = "visibility"
        case windSpeed = "wind_speed"
        case windGust = "wind_gust"
        case windDirection = "wind_deg"
        case probabilityOfPrecipitation = "pop"
        case rain
        case snow
        case weather
    }
}

struct Precipitation: Codable {
    enum CodingKeys: String, CodingKey {
        case unixTime = "dt"
        case precipitation
    }
    
    let unixTime: Int
    let precipitation: Double
}

/// Returns a 1h reading of rain or snow.
struct HourReading: Codable {
    enum CodingKeys: String, CodingKey {
        case hourReading = "1h"
    }
    
    let hourReading: Double?
}

struct WeatherCondition: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case title = "main"
        case description
        case icon
    }
    
    let id: Int
    let title: String
    let description: String
    let icon: String
}

struct Alert: Codable {
    enum CodingKeys: String, CodingKey {
        case source = "sender_name"
        case event
        case start
        case end
        case description
        case tags
    }
    
    let source: String
    let event: String
    let start: Int
    let end: Int
    let description: String
    let tags: [String]
}

struct Temperature: Codable {
    enum CodingKeys: String, CodingKey {
        case morning = "morn"
        case afternoon = "day"
        case evening = "eve"
        case night
        case minimum = "min"
        case maximum = "max"
    }
    
    let morning: Double
    let afternoon: Double
    let evening: Double
    let night: Double
    let minimum: Double?
    let maximum: Double?
}

/// A type that holds 2 different types for the same JSON field name.
enum DualValueDecodable<First: Codable & Sendable, Second: Codable & Sendable>: Codable {
    case first(First)
    case second(Second)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(First.self) {
            self = .first(x)
            return
        }
        
        if let x = try? container.decode(Second.self) {
            self = .second(x)
            return
        }
        
        throw DecodingError.typeMismatch(DualValueDecodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type(s) for DualValueDecodable. Both values should be \(First.self) or \(Second.self)"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .first(let x):
                try container.encode(x)
            case .second(let x):
                try container.encode(x)
        }
    }
}
