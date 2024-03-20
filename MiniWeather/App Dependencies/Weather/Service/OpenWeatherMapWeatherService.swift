//
//  OpenWeatherMapWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapWeatherService<T: TimeZoneWeatherProtocol & Decodable>: WeatherService {
    private let parser: DataParser
    private let timeZoneDatastore: Datastore
    private let networkService: NetworkService
    private let apiKeysProvider: StringPreferenceProvider
    private let weatherRequest: Request?
    
    init(parser: DataParser, timeZoneDatastore: Datastore, networkService: NetworkService, apiKeysProvider: StringPreferenceProvider, weatherRequest: Request? = nil) {
        self.parser = parser
        self.timeZoneDatastore = timeZoneDatastore
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
        self.weatherRequest = weatherRequest
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        let weatherRequest = weatherRequest ?? OpenWeatherMapWeatherRequest(
            queryItems: [
                "lat": String(location.coordinates().latitude),
                "lon": String(location.coordinates().longitude),
                "units": "metric",
                "appid": apiKeysProvider.string(forKey: Settings.openWeatherMapKey) ?? ""
            ]
        )
        
        do {
            let data = try await networkService.getData(from: weatherRequest)
            let weather: T = try parser.decode(data)
            try timeZoneDatastore.store(
                TimeZoneIdentifier(name: weather.timezone, offset: weather.timezoneOffset),
                withKey: .timeZone(name: location.fullName)
            )
            return weather
        } catch {
            throw error
        }
    }
}
