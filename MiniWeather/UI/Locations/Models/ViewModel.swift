//
//  ViewModel.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 08/11/2023.
//

import Foundation
import CoreLocation
import Combine
import SwiftData
import SwiftUI

extension LocationsView {
    @Observable @MainActor final class ViewModel {
        private let userLocationAuthorisationRepositoryFactory: () -> UserLocationAuthorisationRepository
        private let userLocationRepositoryFactory: () -> UserLocationRepository
        private let locationsRepositoryFactory: () -> LocationsRepository
        private let weatherRepositoryFactory: () -> WeatherRepository
        private let timeZoneRepositoryFactory: () -> TimeZoneRepository
        private var status: CLAuthorizationStatus
        var currentLocation: Location? {
            didSet {
                
            }
        }
        // TODO: - replace with Actor object
        private var weatherCache = [UUID: Weather]()
        private var searchResults = [Location]()
        private var searchCancellable: AnyCancellable?
        var searchText = PassthroughSubject<String, Never>()
        
        static let shared = ViewModel(
            userLocationAuthorisationRepositoryFactory: DependencyFactory.shared.makeUserLocationAuthorisationRepository,
            userLocationRepositoryFactory: DependencyFactory.shared.makeUserLocationRepository,
            locationsRepositoryFactory: DependencyFactory.shared.makeLocationsRepository,
            weatherRepositoryFactory: DependencyFactory.shared.makeWeatherRepository,
            timeZoneRepositoryFactory: DependencyFactory.shared.makeTimeZoneRepository
        )
        
        init(
            userLocationAuthorisationRepositoryFactory: @escaping () -> UserLocationAuthorisationRepository,
            userLocationRepositoryFactory: @escaping () -> UserLocationRepository,
            locationsRepositoryFactory: @escaping () -> LocationsRepository,
            weatherRepositoryFactory: @escaping () -> WeatherRepository,
            timeZoneRepositoryFactory: @escaping () -> TimeZoneRepository
        ) {
            self.userLocationAuthorisationRepositoryFactory = userLocationAuthorisationRepositoryFactory
            self.userLocationRepositoryFactory = userLocationRepositoryFactory
            self.locationsRepositoryFactory = locationsRepositoryFactory
            self.weatherRepositoryFactory = weatherRepositoryFactory
            self.timeZoneRepositoryFactory = timeZoneRepositoryFactory
            self.status = userLocationAuthorisationRepositoryFactory().getAuthorisationStatus()
            
            if status != .notDetermined {
                self.currentLocation = getCurrentLocationFromUserDefaults()
            }
        }
        
        func getStatus() -> CLAuthorizationStatus {
            status
        }
        
        func getCurrentLocation() -> Location? {
            currentLocation
        }
        
        func refreshStatus() {
            status = userLocationAuthorisationRepositoryFactory().getAuthorisationStatus()
        }
        
        func getCurrentLocationFromUserDefaults() -> Location? {
            // TODO: Replace use of UserDefaults with proper Datastore.
            let parent = String(describing: Location.self)
            guard 
                let data = UserDefaults.standard.data(forKey: parent + ".timestamp"),
                let date = try? JSONDecoder().decode(Date.self, from: data),
                let uuidData = UserDefaults.standard.data(forKey: parent + ".id"),
                let id = try? JSONDecoder().decode(UUID.self, from: uuidData),
                let city = UserDefaults.standard.string(forKey: parent + ".city"),
                let state = UserDefaults.standard.string(forKey: parent + ".state"),
                let country = UserDefaults.standard.string(forKey: parent + ".country"),
                let nickname = UserDefaults.standard.string(forKey: parent + ".nickname"),
                let timeZone = UserDefaults.standard.string(forKey: parent + ".timeZone"),
                case let latitude = UserDefaults.standard.double(forKey: parent + ".latitude"),
                case let longitude = UserDefaults.standard.double(forKey: parent + ".longitude")
            else {
                refreshCurrentLocation(requestingAuthorisation: false)
                return nil
            }
            
            let location = Location(id: id, timestamp: date, city: city, state: state, country: country, nickname: nickname, timeZone: timeZone, latitide: latitude, longitude: longitude)
            
            // only retrieve weather info if the location isn't outdated since it will be retrieved otherwise
            if !location.isOutdated() {
                getWeather(for: location)
            }
            
            if location.isOutdated() {
                refreshCurrentLocation(requestingAuthorisation: false)
            }
            
            return location
        }
        
        private func saveCurrentLocationToUserDefaults() {
            // TODO: - Replace use of UserDefaults with proper Datastore.
            guard let location = currentLocation else { return }
            let parent = String(describing: Location.self)
            let data = try? JSONEncoder().encode(location.timestamp)
            UserDefaults.standard.set(data, forKey: parent + ".timestamp")
            let uuidData = try? JSONEncoder().encode(location.id)
            UserDefaults.standard.set(uuidData, forKey: parent + ".id")
            UserDefaults.standard.set(location.city, forKey: parent + ".city")
            UserDefaults.standard.set(location.state, forKey: parent + ".state")
            UserDefaults.standard.set(location.country, forKey: parent + ".country")
            UserDefaults.standard.set(location.nickname, forKey: parent + ".nickname")
            UserDefaults.standard.set(location.timeZone, forKey: parent + ".timeZone")
            UserDefaults.standard.set(location.latitude, forKey: parent + ".latitude")
            UserDefaults.standard.set(location.longitude, forKey: parent + ".longitude")
        }
        
        func refreshCurrentLocation(requestingAuthorisation requestAuthorisation: Bool) {
            let userLocationAuthorisationRepository = userLocationAuthorisationRepositoryFactory()
            let userLocationRepository = userLocationRepositoryFactory()
            let locationsRepository = locationsRepositoryFactory()
            let timeZoneRepository = timeZoneRepositoryFactory()
            let weatherRepository = weatherRepositoryFactory()
            
            Task {
                do {
                    let status = await {
                        if requestAuthorisation {
                            let status = await userLocationAuthorisationRepository.requestLocationAuthorisation()
                            await MainActor.run {
                                self.status = status
                            }
                            return status
                        } else {
                            return userLocationAuthorisationRepository.getAuthorisationStatus()
                        }
                    }()
                    
                    if status.isAuthorised() {
                        let coordinates = try await userLocationRepository.getUserLocation()
                        let locations = try await locationsRepository.getLocations(at: coordinates)
                        
                        guard let location = locations.first else {
                            throw LocationError.notFound
                        }
                        
                        let timeZone = try await timeZoneRepository.getTimeZone(
                            at: .init(
                                latitude: location.latitude,
                                longitude: location.longitude
                            )
                        )
                        location.timeZone = timeZone.name
                        let weather = try await weatherRepository.getWeather(for: coordinates)
                        
                        await MainActor.run {
                            // TODO: - replace once actor implementation is done
                            var constantWeatherCache = self.weatherCache
                            self.currentLocation = location
                            self.saveCurrentLocationToUserDefaults()
                            constantWeatherCache[location.id] = weather
                            self.weatherCache = constantWeatherCache
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        func update(_ location: Location, completion: @escaping (TimeZoneIdentifier) -> Void) {
            let weatherRepository = weatherRepositoryFactory()
            let timeZoneRepository = timeZoneRepositoryFactory()
            
            Task {
                let coordinates = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                let weather = try await weatherRepository.getWeather(for: coordinates)
                let timeZone = try await timeZoneRepository.getTimeZone(at: coordinates)
                
                await MainActor.run {
                    // TODO: - replace once actor implementation is done
                    var tempWeather = weatherCache
                    tempWeather[location.id] = weather
                    self.weatherCache = tempWeather
                    completion(timeZone)
                }
            }
        }
        
        func performSearch(for query: String) {
            guard query.count > 2 else {
                searchResults = []
                return
            }
            
            Task {
                let locationsRepository = locationsRepositoryFactory()
                let locations = try await locationsRepository.getLocations(named: query)
                
                await MainActor.run {
                    self.searchResults = locations
                }
            }
        }
        
        func search(for query: String) {
            searchCancellable?.cancel()
            searchCancellable = searchText
                .debounce(
                    for: .milliseconds(600),
                    scheduler: DispatchQueue.main
                )
                .sink { searchQuery in
                    self.performSearch(for: searchQuery)
                }
            searchText.send(query)
        }
        
        func getWeather(for location: Location) {
            Task {
                let weatherRepository = weatherRepositoryFactory()
                let coordinates = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                let weather = try await weatherRepository.getWeather(for: coordinates)
                weatherCache[location.id] = weather
            }
        }
        
        func getWeather(for locations: [Location]) async throws {
            let weatherRepository = weatherRepositoryFactory()
            var weatherInfo = [UUID: Weather]()
            
            for location in locations {
                guard weatherCache[location.id] == nil else {
                    continue
                }
                
                do {
                    let coordinates = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    let weather = try await weatherRepository.getWeather(for: coordinates)
                    weatherInfo[location.id] = weather
                } catch {
                    continue
                }
            }
            
            let constantWeatherInfo = weatherInfo
            
            await MainActor.run {
                constantWeatherInfo.forEach { id, location in
                    weatherCache[id] = location
                }
            }
        }
        
        func weather(for location: Location) -> Binding<Weather?> {
            Binding(
                get: { [weak self] in
                    self?.weatherCache[location.id]
                },
                set: { [weak self] weather in
                    self?.weatherCache[location.id] = weather
                }
            )
        }
        
        func getSearchResults() -> [Location] {
            searchResults
        }
    }
}
