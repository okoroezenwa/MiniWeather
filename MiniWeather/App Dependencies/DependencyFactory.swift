//
//  DependencyFactory.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/10/2023.
//

import Foundation
import CoreLocation

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
        MainLocationsRepository(geocodeService: makeAPINinjasGeocoderService())
    }
    
    public func makeTimeZoneRepository() -> TimeZoneRepository {
        MainTimeZoneRepository(service: makeAPINinjasTimeZoneService())
    }
    
    public func makeWeatherRepository() -> WeatherRepository {
        MainWeatherRepository(weatherService: makeAPINinjasWeatherService())
    }
    
    public func makeUserLocationAuthorisationBroadcaster() -> any Broadcaster<CLAuthorizationStatus> {
        UserLocationAuthorisationBroadcaster(locationManagerDelegate: locationManagerDelegate)
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
