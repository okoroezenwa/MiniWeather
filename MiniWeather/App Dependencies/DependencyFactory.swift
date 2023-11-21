//
//  DependencyFactory.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/10/2023.
//

import Foundation
import CoreLocation

/// The singleton object through which all app dependencies are retrieved.
class DependencyFactory {
    public static let shared = DependencyFactory(
        parser: 
            StandardDataParser(
                decoder: JSONDecoder()
            ),
        networkService:
            StandardNetworkService(
                urlSession: .shared
            ), 
        locationManagerDelegate:
            MainLocationManagerDelegate(
                locationManager: CLLocationManager()
            )
    )
    private let parser: DataParser
    private let networkService: NetworkService
    private let locationManagerDelegate: LocationManagerDelegate
    
    private init(parser: DataParser, networkService: NetworkService, locationManagerDelegate: LocationManagerDelegate) {
        self.parser = parser
        self.networkService = networkService
        self.locationManagerDelegate = locationManagerDelegate
    }
    
    public func makeLocationsRepository() -> LocationsRepository {
        MainLocationsRepository(
            geocodeService: makeAPINinjasGeocoderService()
        )
    }
    
    public func makeTimeZoneRepository() -> TimeZoneRepository {
        MainTimeZoneRepository(
            service: makeAPINinjasTimeZoneService()
        )
    }
    
    public func makeWeatherRepository() -> WeatherRepository {
        MainWeatherRepository(
            weatherService: makeAPINinjasWeatherService()
        )
    }
    
    public func makeUserLocationAuthorisationRepository() -> UserLocationAuthorisationRepository {
        MainUserLocationAuthorisationRepository(
            userLocationAuthorisationProvider: makeUserLocationAuthorisationProvider()
        )
    }
    
    public func makeUserLocationRepository() -> UserLocationRepository {
        MainUserLocationRepository(
            userLocationProvider: makeUserLocationProvider()
        )
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
    
    private func makeUserLocationProvider() -> UserLocationProvider {
        locationManagerDelegate
    }
    
    private func makeUserLocationAuthorisationProvider() -> UserLocationAuthorisationProvider {
        locationManagerDelegate
    }
}
