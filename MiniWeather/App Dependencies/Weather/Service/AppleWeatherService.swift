//
//  AppleWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 10/12/2023.
//

import Foundation
import WeatherKit

struct AppleWeatherService: WeatherService {
    private let service: WeatherKit.WeatherService
    
    init(service: WeatherKit.WeatherService) {
        self.service = service
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        do {
            return try await service.weather(for: .init(latitude: location.latitude, longitude: location.longitude))
        } catch {
            throw error
        }
    }
}
