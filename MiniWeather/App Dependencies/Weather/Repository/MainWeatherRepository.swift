//
//  MainWeatherRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

struct MainWeatherRepository: WeatherRepository {
    private let weatherService: WeatherService
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        try await weatherService.getWeather(for: location)
    }
}
