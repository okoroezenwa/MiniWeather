//
//  OpenWeatherMapWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapWeatherService: WeatherService {
    private let networkService: NetworkService
    private let timeZoneDatastore: Datastore
    private let parser: DataParser
    
    init(networkService: NetworkService, timeZoneDatastore: Datastore, parser: DataParser) {
        self.networkService = networkService
        self.timeZoneDatastore = timeZoneDatastore
        self.parser = parser
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        let weatherRequest = OpenWeatherMapWeatherRequest(
            queryItems: [
                "lat": String(location.coordinates().latitude),
                "lon": String(location.coordinates().longitude),
                "units": "metric",
                "appid": "b70953dbe7338b90a67f650598d6e321"
            ]
        )
        
        do {
            let data = try await networkService.getData(from: weatherRequest)
            let weather: OpenWeatherMapWeather = try parser.decode(data)
            try timeZoneDatastore.store(
                TimeZoneIdentifier(name: weather.timezone),
                withKey: .timeZone(name: location.fullName)
            )
            return weather
        } catch {
            throw error
        }
    }
}
