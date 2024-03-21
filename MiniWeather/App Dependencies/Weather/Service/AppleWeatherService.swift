//
//  AppleWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 10/12/2023.
//

import Foundation
import WeatherKit
import CoreLocation

struct AppleWeatherService<T: WeatherProtocol>: WeatherService {
    private let provider: WeatherProvider
    
    init(provider: WeatherProvider) {
        self.provider = provider
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        do {
            let weather: T = try await provider.getWeather(for: .init(latitude: location.latitude, longitude: location.longitude))
            return weather
        } catch {
            throw error
        }
    }
}

#warning("Move elsewhere later")
protocol WeatherProvider {
    func getWeather<T: WeatherProtocol>(for location: CLLocation) async throws -> T
}

extension WeatherKit.WeatherService: WeatherProvider {
    func getWeather<T>(for location: CLLocation) async throws -> T where T : WeatherProtocol {
        guard let weather = try await weather(for: location) as? T else {
            throw TypeError.typeMismatch
        }
        return weather
    }
}
