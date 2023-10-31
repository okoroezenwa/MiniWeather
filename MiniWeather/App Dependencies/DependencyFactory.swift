//
//  DependencyFactory.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/10/2023.
//

import Foundation

class DependencyFactory {
    public static let shared = DependencyFactory(
        parser: 
            StandardDataParser(
                decoder: JSONDecoder()
            ),
        networkService:
            StandardNetworkService(
                urlSession: .shared
            )
    )
    private let parser: DataParser
    private let networkService: NetworkService
    
    private init(parser: DataParser, networkService: NetworkService) {
        self.parser = parser
        self.networkService = networkService
    }
    
    public func makeLocationsRepository() -> LocationsRepository {
        MainLocationsRepository(geocodeService: makeAPINinjasGeocoderService())
    }
    
    public func makeTimeZoneRepository() -> TimeZoneRepository {
        MainTimeZoneRepository(service: makeAPINinjasTimeZoneService())
    }
    
    public func makeWeatherRepository() -> WeatherRepository {
        MainWeatherRepository(weatherService: makeAPINinjasWeatherService())
    }
    
    private func makeAppleGeocoderService() -> GeocoderService {
        AppleGeocoderService()
    }
    
    private func makeAPINinjasGeocoderService() -> GeocoderService {
        APINinjasGeodecoderService(
            networkService: networkService,
            parser: parser
        )
    }
    
    private func makeAPINinjasTimeZoneService() -> TimeZoneService {
        APINinjasTimeZoneService(
            networkService: networkService,
            parser: parser
        )
    }
    
    private func makeAPINinjasWeatherService() -> WeatherService {
        APINinjasWeatherService(
            networkService: networkService,
            parser: parser
        )
    }
}
