//
//  APINinjasWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

struct APINinjasWeatherService<T: WeatherProtocol & Decodable>: WeatherService {
    private let parser: DataParser
    private let networkService: NetworkService
    private let apiKeysProvider: PreferencesProvider
    private let weatherRequest: Request?
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: PreferencesProvider, weatherRequest: Request? = nil) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
        self.weatherRequest = weatherRequest
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        let weatherRequest = weatherRequest ?? APINinjasWeatherRequest(
            queryItems: [
                "lat": String(location.coordinates().latitude),
                "lon": String(location.coordinates().longitude)
            ],
            headers: ["X-Api-Key": apiKeysProvider.string(forKey: Settings.apiNinjasKey) ?? ""]
        )
        
        do {
            let data = try await networkService.getData(from: weatherRequest)
            let weather: T = try parser.decode(data)
            return weather
        } catch {
            throw error
        }
    }
}
