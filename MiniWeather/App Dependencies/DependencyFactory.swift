//
//  DependencyFactory.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/10/2023.
//

import Foundation
import CoreLocation
import OSLog
import WeatherKit

/// The singleton object through which all app dependencies are retrieved.
final class DependencyFactory {
    public static let shared = DependencyFactory(
        locationManagerDelegate:
            MainLocationManagerDelegate(
                locationManager: CLLocationManager()
            ),
        temporaryStore: StandardTemporaryStore(), 
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
            geocodeService: makePreferredGeocoderService()
        )
    }
    
    public func makeTimeZoneRepository() -> TimeZoneRepository {
        MainTimeZoneRepository(
            service: makePreferredTimeZoneService()
        )
    }
    
    public func makeWeatherRepository() -> WeatherRepository {
        MainWeatherRepository(
            weatherService: makePreferredWeatherService()
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
        AppleGeocoderService<CLPlacemark>(geocoder: CLGeocoder())
    }
    
    private func makeAPINinjasGeocoderService() -> GeocoderService {
        APINinjasGeocoderService<APINinjasLocation, APINinjasTemporaryLocation>(
            parser: makeStandardDataParser(),
            networkService: makeStandardNetworkService(), 
            apiKeysProvider: makeMainStringPreferenceProvider()
        )
    }
    
    private func makeOpenWeatherMapGeocoderService() -> GeocoderService {
        OpenWeatherMapGeocoderService<OpenWeatherMapLocation>(
            parser: makeStandardDataParser(),
            networkService: makeStandardNetworkService(),
            apiKeysProvider: makeMainStringPreferenceProvider()
        )
    }
    
    private func makePreferredGeocoderService() -> GeocoderService {
        let preferredService: Service = Settings.currentValue(for: Settings.geocoderService)
        
        switch preferredService {
            case .apple:
                return makeAppleGeocoderService()
            case .apiNinjas:
                return makeAPINinjasGeocoderService()
            case .openWeatherMap:
                return makeOpenWeatherMapGeocoderService()
        }
    }
    
    private func makeAPINinjasTimeZoneService() -> TimeZoneService {
        APINinjasTimeZoneService(
            parser: makeStandardDataParser(), 
            networkService: makeStandardNetworkService(),
            apiKeysProvider: makeMainStringPreferenceProvider()
        )
    }
    
    private func makeOpenWeatherMapTimeZoneService() -> TimeZoneService {
        OpenWeatherMapTimeZoneService<CLPlacemark>(
            cache: makeMemoryDatastore(),
            geocoder: CLGeocoder(), 
            weatherService: Settings.currentValue(for: Settings.weatherProvider)
        )
    }
    
    private func makePreferredTimeZoneService() -> TimeZoneService {
        let preferredService: Service = Settings.currentValue(for: Settings.geocoderService)
        
        switch preferredService {
            case .apple, .openWeatherMap:
                return makeOpenWeatherMapTimeZoneService()
            case .apiNinjas:
                return makeAPINinjasTimeZoneService()
        }
    }
    
    private func makeAPINinjasWeatherService() -> WeatherService {
        APINinjasWeatherService<APINinjasWeather>(
            parser: makeStandardDataParser(),
            networkService: makeStandardNetworkService(),
            apiKeysProvider: makeMainStringPreferenceProvider()
        )
    }
    
    private func makeOpenWeatherMapWeatherService() -> WeatherService {
        OpenWeatherMapWeatherService<OpenWeatherMapWeather>(
            parser: makeStandardDataParser(),
            timeZoneDatastore: makeMemoryDatastore(),
            networkService: makeStandardNetworkService(),
            apiKeysProvider: makeMainStringPreferenceProvider()
        )
    }
    
    private func makeAppleWeatherService() -> WeatherService {
        AppleWeatherService<WeatherKit.Weather>(
            provider: WeatherKit.WeatherService.shared
        )
    }
    
    private func makePreferredWeatherService() -> WeatherService {
        let preferredService: Service = Settings.currentValue(for: Settings.weatherProvider)
        
        switch preferredService {
            case .apple:
                return makeAppleWeatherService()
            case .openWeatherMap:
                return makeOpenWeatherMapWeatherService()
            case .apiNinjas:
                return makeAPINinjasWeatherService()
        }
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
            datastore: makeUserDefaultsDatastore(),
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
    
    private func makeMainStringPreferenceProvider() -> StringPreferenceProvider {
        UserDefaults.standard
    }
}
