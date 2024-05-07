//
//  DependencyFactory.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/10/2023.
//

import CoreLocation
import OSLog
import WeatherKit
import DiskCache
import CloudKit

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
    private static let cloudKitIdentifier = "iCloud.okoroezenwa.MiniWeather"
    
    private let locationManagerDelegate: LocationManagerDelegate
    private let temporaryStore: TemporaryStore
    private let cloudDatastoreUpdateHandler: CloudKeyValueDatastoreUpdateHandler
    private lazy var syncEngineDelegate = makeSyncEngineDelegate()
    
    private init(
        locationManagerDelegate: LocationManagerDelegate,
        temporaryStore: TemporaryStore,
        cloudDatastoreUpdateHandler: CloudKeyValueDatastoreUpdateHandler
    ) {
        self.locationManagerDelegate = locationManagerDelegate
        self.temporaryStore = temporaryStore
        self.cloudDatastoreUpdateHandler = cloudDatastoreUpdateHandler
    }
    
    func startSyncEngine() {
        syncEngineDelegate.start()
    }
    
    // MARK: - Standard Repositories
    
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
    
    public func makePreferencesRepository() -> PreferencesRepository {
        MainPreferencesRepository(
            provider: makeMainPreferencesProvider()
        )
    }
    
    public func makeSyncEngineOperationsRepository() -> SyncEngineOperationsRepository {
        MainSyncEngineOperationsRepository(
            provider: makeSyncEngineOperationsProvider()
        )
    }
    
    // MARK: - Datastores
    
    private func makeTemporalFileDatastore() -> Datastore {
        FileDatastore(
            cache: makeTemporalDiskCache(),
            encoder: makeJSONDataEncoder(),
            decoder: makeJSONDataDecoder(),
            logger: Logger()
        )
    }
    
    private func makePermanentFileDatastore() -> Datastore {
        FileDatastore(
            cache: makePermanentDiskCache(),
            encoder: makeJSONDataEncoder(),
            decoder: makeJSONDataDecoder(),
            logger: Logger()
        )
    }
    
    private func makeMemoryDatastore() -> Datastore {
        MemoryDatastore(
            store: temporaryStore,
            logger: Logger()
        )
    }
    
    private func makeUserDefaultsDatastore() -> Datastore {
        UserDefaultsDatastore(
            store: makeUserDefaultsKeyValueStore(),
            decoder: makeJSONDataDecoder(),
            encoder: makeJSONDataEncoder(),
            logger: Logger()
        )
    }
    
    private func makeCloudKeyValueDatastore() -> Datastore {
        CloudKeyValueDatastore(
            cloudStore: makeCloudKeyValueStore(),
            localStore: makeUserDefaultsKeyValueStore(), 
            decoder: makeJSONDataDecoder(),
            encoder: makeJSONDataEncoder(),
            logger: Logger()
        )
    }
    
    // MARK: - Services
    
    private func makeAppleGeocoderService() -> GeocoderService {
        AppleGeocoderService<CLPlacemark>(geocoder: CLGeocoder())
    }
    
    private func makeAPINinjasGeocoderService() -> GeocoderService {
        APINinjasGeocoderService<APINinjasLocation, APINinjasTemporaryLocation>(
            parser: makeStandardDataParser(),
            networkService: makeStandardNetworkService(), 
            apiKeysProvider: makeMainPreferencesProvider()
        )
    }
    
    private func makeOpenWeatherMapGeocoderService() -> GeocoderService {
        OpenWeatherMapGeocoderService<OpenWeatherMapLocation>(
            parser: makeStandardDataParser(),
            networkService: makeStandardNetworkService(),
            apiKeysProvider: makeMainPreferencesProvider()
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
            apiKeysProvider: makeMainPreferencesProvider()
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
            apiKeysProvider: makeMainPreferencesProvider()
        )
    }
    
    private func makeOpenWeatherMapWeatherService() -> WeatherService {
        OpenWeatherMapWeatherService<OpenWeatherMapWeather>(
            parser: makeStandardDataParser(),
            timeZoneDatastore: makeMemoryDatastore(),
            networkService: makeStandardNetworkService(),
            apiKeysProvider: makeMainPreferencesProvider()
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
    
    // MARK: - Providers
    
    private func makeUserLocationProvider() -> UserLocationCoordinatesProvider {
        locationManagerDelegate
    }
    
    private func makeUserLocationAuthorisationProvider() -> UserLocationAuthorisationProvider {
        locationManagerDelegate
    }
    
    private func makeCurrentLocationProvider() -> CurrentLocationProvider {
        MainCurrentLocationProvider(
            store: makeTemporalFileDatastore(),
            userLocationAuthorisationProvider: makeUserLocationAuthorisationProvider(),
            logger: Logger()
        )
    }
    
    private func makeSavedLocationsProvider() -> SavedLocationsProvider {
        MainSavedLocationsProvider(
            datastore: makePermanentFileDatastore(),
            logger: Logger(), 
            intPreferenceProvider: makeMainPreferencesProvider()
        )
    }
    
    private func makeCloudKitRecordsProvider() -> CloudKitRecordsProvider {
        MainCloudKitRecordsProvider(
            datastore: makePermanentFileDatastore(),
            encoder: makeJSONDataEncoder(),
            decoder: makeJSONDataDecoder()
        )
    }
    
    private func makeSyncEngineStateSerialisationProvider() -> SyncEngineStateSerialisationProvider {
        MainSyncEngineStateSerialisationProvider(
            datastore: makePermanentFileDatastore()
        )
    }
    
    private func makeCloudKitUserAccountStatusProvider() -> CloudKitUserAccountStatusProvider {
        MainCloudKitUserAccountStatusProvider(
            container: makeCloudKitContainer()
        )
    }
    
    private func makeSyncEngineOperationsProvider() -> SyncEngineOperationsProvider {
        MainSyncEngineOperationsProvider(
            syncEngineDelegate: makeSyncEngineDelegate(),
            recordProvider: makeCloudKitRecordsProvider(),
            userAccountStatusProvider: makeCloudKitUserAccountStatusProvider()
        )
    }
    
    // MARK: - CloudKit Container
    
    private func makeCloudKitContainer() -> CKContainer {
        CKContainer(identifier: Self.cloudKitIdentifier)
    }
    
    // MARK: - CloudKit Databases
    
    private func makePublicCloudKitDatabase() -> CKDatabase {
        makeCloudKitContainer().publicCloudDatabase
    }
    
    private func makePrivateCloudKitDatabase() -> CKDatabase {
        makeCloudKitContainer().privateCloudDatabase
    }
    
    private func makeSharedCloudKitDatabase() -> CKDatabase {
        makeCloudKitContainer().sharedCloudDatabase
    }
    
    // MARK: - Key-Value Stores
    
    private func makeUserDefaultsKeyValueStore() -> KeyValueStore {
        UserDefaults.standard
    }
    
    private func makeCloudKeyValueStore() -> KeyValueStore {
        NSUbiquitousKeyValueStore.default
    }
    
    // MARK: - Sync Engine
    
    private func makeSyncEngineDelegate() -> SyncEngineDelegate {
        MainSyncEngineDelegate(
            database: makePrivateCloudKitDatabase(),
            recordProvider: makeCloudKitRecordsProvider(),
            savedLocationsProvider: makeSavedLocationsProvider(),
            serialisationProvider: makeSyncEngineStateSerialisationProvider()
        )
    }
    
    // MARK: - Caches
    
    private func makeTemporalDiskCache() -> Cache {
        do {
            return try DiskCache(storageType: .temporary(nil))
        } catch {
            fatalError("Caches directory not found")
        }
    }
    
    private func makePermanentDiskCache() -> Cache {
        do {
            return try DiskCache(storageType: .permanent(nil))
        } catch {
            fatalError("Main directory not found")
        }
    }
    
    // MARK: - Network
    
    private func makeStandardNetworkService() -> NetworkService {
        StandardNetworkService(
            urlSession: .shared
        )
    }
    
    // MARK: - Parser
    
    private func makeStandardDataParser() -> DataParser {
        StandardDataParser(
            decoder: makeJSONDataDecoder()
        )
    }
    
    // MARK: - Decoders & Encoders
    
    private func makeJSONDataDecoder() -> DataDecoder {
        JSONDecoder()
    }
    
    private func makeJSONDataEncoder() -> DataEncoder {
        JSONEncoder()
    }
    
    // MARK: - Preferences
    
    private func makeMainPreferencesProvider() -> PreferencesProvider {
        UserDefaults.standard
    }
}
