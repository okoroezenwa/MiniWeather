//
//  APINinjasWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

struct APINinjasWeatherService: WeatherService {
    private let parser: DataParser
    private let networkService: NetworkService
    private let apiKeysProvider: APIKeysProvider
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: APIKeysProvider) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        let weatherRequest = APINinjasWeatherRequest(
            queryItems: [
                "lat": String(location.coordinates().latitude),
                "lon": String(location.coordinates().longitude)
            ],
            headers: ["X-Api-Key": apiKeysProvider.getAPIKey(for: Settings.apiNinjasKey)]
        )
        
        do {
            let data = try await networkService.getData(from: weatherRequest)
            let weather: APINinjasWeather = try parser.decode(data)
            return weather
        } catch {
            throw error
        }
    }
}
