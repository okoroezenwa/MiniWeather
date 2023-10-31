//
//  MainWeatherRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

class MainWeatherRepository: WeatherRepository {
    private let weatherService: WeatherService
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    func getWeather(for coordinates: CLLocationCoordinate2D) async throws -> Weather {
        try await weatherService.getWeather(at: coordinates)
    }
}
