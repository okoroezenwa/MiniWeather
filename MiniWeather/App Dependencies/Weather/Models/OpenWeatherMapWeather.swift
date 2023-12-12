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
    let alerts: [Alert]?
}

// MARK: - WeatherProtocol Conformance 😮‍💨
extension OpenWeatherMapWeather: WeatherProtocol {
    
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
        guard let sunrise = currentWeather.sunrise else {
            fatalError("Sunrise info missing for current weather")
        }
        
        return sunrise
    }
    
    var sunset: Date? {
        guard let sunset = currentWeather.sunset else {
            fatalError("Sunset info missing for current weather")
        }
        
        return sunset
    }
    
    var cloudPercentage: Double {
        currentWeather.clouds
    }
    
    var symbol: String {
        guard let title = currentWeather.weather.first?.title, let description = currentWeather.weather.first?.description else {
            return ""
        }
        switch (title, description) {
            case ("Thunderstorm", _): 
                return "cloud.bolt.rain"
            case ("Drizzle", _):
                return "cloud.drizzle"
            case ("Rain", "freezing rain"),
                ("Snow", _):
                return "snowflake"
            case ("Rain", let description):
                switch description {
                    case "light rain",
                        "moderate rain":
                        return "cloud.sun.rain"
                    case "light intensity shower rain",
                        "shower rain",
                        "ragged shower rain":
                        return "cloud.rain"
                    case "heavy intensity shower rain",
                        "heavy intensity rain",
                        "very heavy rain",
                        "extreme rain":
                        return "cloud.heavyrain"
                    default:
                        return "cloud.rain"
                }
            case ("Atmosphere", let description):
                switch description {
                    case "smoke":
                        return "smoke"
                    case "haze":
                        return "sun.haze"
                    case "sand/dust whirls",
                        "dust":
                        return "sun.dust"
                    case "tornado":
                        return "tornado"
                    default:
                        return "cloud.fog"
                }
            case ("Clear", _):
                return "sun.max"
            case ("Clouds", let description):
                switch description {
                    case "few clouds":
                        return "cloud.sun"
                    case "scattered clouds":
                        return "cloud"
                    case "broken clouds",
                        "overcast clouds":
                        return "smoke"
                    default:
                        return "cloud"
                }
            default:
                return ""
        }
    }
}
