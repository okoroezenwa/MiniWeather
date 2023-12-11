//
//  OpenWeatherMapWeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapWeatherService: WeatherService {
    private let parser: DataParser
    private let timeZoneDatastore: Datastore
    private let networkService: NetworkService
    private let stringPreferenceProvider: StringPreferenceProvider
    
    init(parser: DataParser, timeZoneDatastore: Datastore, networkService: NetworkService, stringPreferenceProvider: StringPreferenceProvider) {
        self.parser = parser
        self.timeZoneDatastore = timeZoneDatastore
        self.networkService = networkService
        self.stringPreferenceProvider = stringPreferenceProvider
    }
    
    func getWeather(for location: Location) async throws -> WeatherProtocol {
        let weatherRequest = OpenWeatherMapWeatherRequest(
            queryItems: [
                "lat": String(location.coordinates().latitude),
                "lon": String(location.coordinates().longitude),
                "units": getUnitsStringPreference(),
                "appid": stringPreferenceProvider.string(forKey: Settings.openWeatherMapKey) ?? ""
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
    
    private func getUnitsStringPreference() -> String {
        guard let string = stringPreferenceProvider.string(forKey: Settings.openWeatherMapKey), let unit = UnitOfMeasure(rawValue: string) else {
            return UnitOfMeasure.default.rawValue.lowercased()
        }
        
        switch unit {
            case .scientific: 
                return "standard"
            case .metric, .imperial:
                return unit.rawValue.lowercased()
        }
    }
}
