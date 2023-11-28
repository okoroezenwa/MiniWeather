//
//  DependencyFactory.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/10/2023.
//

import Foundation
import CoreLocation
import OSLog

/// The singleton object through which all app dependencies are retrieved.
final class DependencyFactory {
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
            ),
        temporaryStore: TemporaryStore()
    )
    private let parser: DataParser
    private let networkService: NetworkService
    private let locationManagerDelegate: LocationManagerDelegate
    private let temporaryStore: TemporaryStore
    
    private init(
        parser: DataParser,
        networkService: NetworkService,
        locationManagerDelegate: LocationManagerDelegate,
        temporaryStore: TemporaryStore
    ) {
        self.parser = parser
        self.networkService = networkService
        self.locationManagerDelegate = locationManagerDelegate
        self.temporaryStore = temporaryStore
    }
    
    public func makeLocationsSearchRepository() -> LocationsSearchRepository {
        MainLocationsSearchRepository(
            geocodeService: makeOpenWeatherMapGeocoderService()
        )
    }
    
    public func makeTimeZoneRepository() -> TimeZoneRepository {
        MainTimeZoneRepository(
            service: makeOpenWeatherMapTimeZoneService()
        )
    }
    
    public func makeWeatherRepository() -> WeatherRepository {
        MainWeatherRepository(
            weatherService: makeOpenWeatherMapWeatherService()
        )
    }
    
    public func makeUserLocationAuthorisationRepository() -> UserLocationAuthorisationRepository {
        MainUserLocationAuthorisationRepository(
            userLocationAuthorisationProvider: makeUserLocationAuthorisationProvider()
        )
    }
    
    public func makeUserLocationCoordinatesRepository() -> UserLocationCoordinatesRepository {
        MainUserLocationCoordinatesRepository(
            userLocationProvider: makeUserLocationProvider()
        )
    }
    
    public func makeCurrentLocationRepository() -> CurrentLocationRepository {
        MainCurrentLocationRepository(
            provider: makeCurrentLocationProvider()
        )
    }
    
    public func makeSavedLocationsRepository() -> SavedLocationsRepository {
        MainSavedLocationsRepository(
            provider: makeSavedLocationsProvider()
        )
    }
    
    public func makeMemoryDatastore() -> Datastore {
        MemoryDatastore(
            store: temporaryStore,
            logger: Logger()
        )
    }
    
    public func makeUserDefaultsDatastore() -> Datastore {
        UserDefaultsDatastore(
            store: makeUserDefaultsKeyValueStore(),
            decoder: JSONDecoder(),
            encoder: JSONEncoder(),
            logger: Logger()
        )
    }
    
    public func makeCloudKeyValueDatastore() -> Datastore {
        CloudKeyValueDatastore(
            store: makeCloudKeyValueStore(),
            decoder: JSONDecoder(),
            encoder: JSONEncoder(),
            localStorage: makeUserDefaultsKeyValueStore(),
            logger: Logger()
        )
    }
    
    private func makeAppleGeocoderService() -> GeocoderService {
        AppleGeocoderService()
    }
    
    private func makeAPINinjasGeocoderService() -> GeocoderService {
        APINinjasGeocoderService(
            networkService: networkService,
            parser: parser
        )
    }
    
    private func makeOpenWeatherMapGeocoderService() -> GeocoderService {
        OpenWeatherMapGeocoderService(
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
    
    private func makeOpenWeatherMapTimeZoneService() -> TimeZoneService {
        OpenWeatherMapTimeZoneService(
            cache: makeMemoryDatastore()
        )
    }
    
    private func makeAPINinjasWeatherService() -> WeatherService {
        APINinjasWeatherService(
            networkService: networkService,
            parser: parser
        )
    }
    
    private func makeOpenWeatherMapWeatherService() -> WeatherService {
        OpenWeatherMapWeatherService(
            networkService: networkService,
            timeZoneDatastore: makeMemoryDatastore(),
            parser: parser
        )
    }
    
    private func makeUserLocationProvider() -> UserLocationProvider {
        locationManagerDelegate
    }
    
    private func makeUserLocationAuthorisationProvider() -> UserLocationAuthorisationProvider {
        locationManagerDelegate
    }
    
    private func makeCurrentLocationProvider() -> CurrentLocationProvider {
        MainCurrentLocationProvider(
            store: makeUserDefaultsDatastore(),
            userLocationAuthorisationProvider: makeUserLocationAuthorisationProvider(),
            logger: Logger()
        )
    }
    
    private func makeSavedLocationsProvider() -> SavedLocationsProvider {
        MainSavedLocationsProvider(
            datastore: makeCloudKeyValueDatastore(),
            logger: Logger()
        )
    }
    
    private func makeUserDefaultsKeyValueStore() -> KeyValueStore {
        UserDefaults.standard
    }
    
    private func makeCloudKeyValueStore() -> KeyValueStore {
        NSUbiquitousKeyValueStore.default
    }
}
