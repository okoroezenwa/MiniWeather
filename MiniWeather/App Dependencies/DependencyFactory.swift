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
        locationManagerDelegate:
            MainLocationManagerDelegate(
                locationManager: CLLocationManager()
            ),
        temporaryStore: TemporaryStore(), 
        cloudDatastoreUpdateHandler:
            CloudKeyValueDatastoreUpdateHandler(
                cloudStore: NSUbiquitousKeyValueStore.default,
                localStore: UserDefaults.standard,
                logger: Logger()
            )
    )
    private let locationManagerDelegate: LocationManagerDelegate
    private let temporaryStore: TemporaryStore
    private let cloudDatastoreUpdateHandler: CloudKeyValueDatastoreUpdateHandler
    
    private init(
        locationManagerDelegate: LocationManagerDelegate,
        temporaryStore: TemporaryStore,
        cloudDatastoreUpdateHandler: CloudKeyValueDatastoreUpdateHandler
    ) {
        self.locationManagerDelegate = locationManagerDelegate
        self.temporaryStore = temporaryStore
        self.cloudDatastoreUpdateHandler = cloudDatastoreUpdateHandler
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
            cloudStore: makeCloudKeyValueStore(),
            localStore: makeUserDefaultsKeyValueStore(), 
            decoder: JSONDecoder(),
            encoder: JSONEncoder(),
            logger: Logger()
        )
    }
    
    private func makeAppleGeocoderService() -> GeocoderService {
        AppleGeocoderService()
    }
    
    private func makeAPINinjasGeocoderService() -> GeocoderService {
        APINinjasGeocoderService(
            networkService: makeStandardNetworkService(),
            parser: makeStandardDataParser()
        )
    }
    
    private func makeOpenWeatherMapGeocoderService() -> GeocoderService {
        OpenWeatherMapGeocoderService(
            networkService: makeStandardNetworkService(),
            parser: makeStandardDataParser()
        )
    }
    
    private func makeAPINinjasTimeZoneService() -> TimeZoneService {
        APINinjasTimeZoneService(
            networkService: makeStandardNetworkService(),
            parser: makeStandardDataParser()
        )
    }
    
    private func makeOpenWeatherMapTimeZoneService() -> TimeZoneService {
        OpenWeatherMapTimeZoneService(
            cache: makeMemoryDatastore()
        )
    }
    
    private func makeAPINinjasWeatherService() -> WeatherService {
        APINinjasWeatherService(
            networkService: makeStandardNetworkService(),
            parser: makeStandardDataParser()
        )
    }
    
    private func makeOpenWeatherMapWeatherService() -> WeatherService {
        OpenWeatherMapWeatherService(
            networkService: makeStandardNetworkService(),
            timeZoneDatastore: makeMemoryDatastore(),
            parser: makeStandardDataParser()
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
    
    private func makeStandardNetworkService() -> NetworkService {
        StandardNetworkService(
            urlSession: .shared
        )
    }
    
    private func makeStandardDataParser() -> DataParser {
        StandardDataParser(
            decoder: JSONDecoder()
        )
    }
}
