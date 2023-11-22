//
//  APINinjasWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

struct APINinjasWeatherService: WeatherService {
    private let networkService: NetworkService
    private let parser: DataParser
    
    init(networkService: NetworkService, parser: DataParser) {
        self.networkService = networkService
        self.parser = parser
    }
    
    func getWeather(at coordinates: CLLocationCoordinate2D) async throws -> Weather {
        let weatherRequest = APINinjasWeatherRequest(
            queryItems: [
                "lat": String(coordinates.latitude),
                "lon": String(coordinates.longitude)
            ],
            headers: ["X-Api-Key": "S7/jrjbcI+0knImPq9dH9Q==lNZI74iBzjtGlZjR"]
        )
        
        do {
            let data = try await networkService.getData(from: weatherRequest)
            let weather: Weather = try parser.decode(data)
            return weather
        } catch {
            throw error
        }
    }
}
