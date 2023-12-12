//
//  OpenWeatherMapCodables.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation
import WeatherKit

struct WeatherForecast: Codable {
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
    
    let unixTime: Int
    let sunrise: Date?
    let sunset: Date?
    let moonrise: Int?
    let moonset: Int?
    let moonPhase: Double?
    let summary: String?
    let temperature: DualValueDecodable<Measurement<UnitTemperature>, Temperature> // Daily uses Temperature, others use Double
    let feelsLike: DualValueDecodable<Measurement<UnitTemperature>, Temperature> // Daily uses Temperature, others use Double
    let pressure: Double?
    let humidity: Double?
    let dewPoint: Double?
    let uvIndex: Double?
    let clouds: Double
    let visibility: Double?
    let windSpeed: Measurement<UnitSpeed>?
    let windGust: Double?
    let windDirection: Measurement<UnitAngle>?
    let probabilityOfPrecipitation: Double?
    let rain: DualValueDecodable<Double, HourReading>? // Daily uses Double, others use HourReading
    let snow: DualValueDecodable<Double, HourReading>? // Daily uses Double, others use HourReading
    let weather: [WeatherCondition]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.unixTime = try container.decode(Int.self, forKey: .unixTime)
        
        let sunrise = try container.decodeIfPresent(TimeInterval.self, forKey: .sunrise)
        if let sunrise {
            self.sunrise = Date(timeIntervalSince1970: sunrise)
        } else {
            self.sunrise = nil
        }
        
        let sunset = try container.decodeIfPresent(TimeInterval.self, forKey: .sunset)
        if let sunset {
            self.sunset = Date(timeIntervalSince1970: sunset)
        } else {
            self.sunset = nil
        }
        
        self.moonrise = try container.decodeIfPresent(Int.self, forKey: .moonrise)
        self.moonset = try container.decodeIfPresent(Int.self, forKey: .moonset)
        self.moonPhase = try container.decodeIfPresent(Double.self, forKey: .moonPhase)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        
        let temperature = try container.decode(DualValueDecodable<Double, Temperature>.self, forKey: .temperature)
        self.temperature = {
            switch temperature {
                case .first(let double):
                    return .first(Measurement(value: double, unit: .celsius))
                case .second(let temperature):
                    return .second(temperature)
            }
        }()
        
        let feelsLike = try container.decode(DualValueDecodable<Double, Temperature>.self, forKey: .feelsLike)
        self.feelsLike = {
            switch feelsLike {
                case .first(let double):
                    return .first(Measurement(value: double, unit: .celsius))
                case .second(let temperature):
                    return .second(temperature)
            }
        }()
        
        self.pressure = try container.decodeIfPresent(Double.self, forKey: .pressure)
        self.humidity = try container.decodeIfPresent(Double.self, forKey: .humidity)
        self.dewPoint = try container.decodeIfPresent(Double.self, forKey: .dewPoint)
        self.clouds = try container.decode(Double.self, forKey: .clouds)
        self.uvIndex = try container.decodeIfPresent(Double.self, forKey: .uvIndex)
        self.visibility = try container.decodeIfPresent(Double.self, forKey: .visibility)
        let windSpeed = try container.decodeIfPresent(Double.self, forKey: .windSpeed)
        if let windSpeed {
            self.windSpeed = Measurement(value: windSpeed, unit: .metersPerSecond)
        } else {
            self.windSpeed = nil
        }
        
        self.windGust = try container.decodeIfPresent(Double.self, forKey: .windGust)
        let windDirection = try container.decodeIfPresent(Double.self, forKey: .windDirection)
        if let windDirection {
            self.windDirection = Measurement(value: windDirection, unit: .degrees)
        } else {
            self.windDirection = nil
        }
        
        self.probabilityOfPrecipitation = try container.decodeIfPresent(Double.self, forKey: .probabilityOfPrecipitation)
        self.rain = try container.decodeIfPresent(DualValueDecodable<Double, HourReading>.self, forKey: .rain)
        self.snow = try container.decodeIfPresent(DualValueDecodable<Double, HourReading>.self, forKey: .snow)
        self.weather = try container.decode([WeatherCondition].self, forKey: .weather)
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
    
    let morning: Measurement<UnitTemperature>
    let afternoon: Measurement<UnitTemperature>
    let evening: Measurement<UnitTemperature>
    let night: Measurement<UnitTemperature>
    let minimum: Measurement<UnitTemperature>?
    let maximum: Measurement<UnitTemperature>?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let morning = try container.decode(Double.self, forKey: .morning)
        self.morning = Measurement(value: morning, unit: .celsius)
        
        let afternoon = try container.decode(Double.self, forKey: .afternoon)
        self.afternoon = Measurement(value: afternoon, unit: .celsius)
        
        let evening = try container.decode(Double.self, forKey: .evening)
        self.evening = Measurement(value: evening, unit: .celsius)
        
        let night = try container.decode(Double.self, forKey: .night)
        self.night = Measurement(value: night, unit: .celsius)
        
        let minimum = try container.decodeIfPresent(Double.self, forKey: .minimum)
        if let minimum {
            self.minimum = Measurement(value: minimum, unit: .celsius)
        } else {
            self.minimum = nil
        }
        
        let maximum = try container.decodeIfPresent(Double.self, forKey: .maximum)
        if let maximum {
            self.maximum = Measurement(value: maximum, unit: .celsius)
        } else {
            self.maximum = nil
        }
    }
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
