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

extension LocationsView {
    @Observable class ViewModel {
        private let userLocationAuthorisationRepositoryFactory: () -> UserLocationAuthorisationRepository
        private let userLocationRepositoryFactory: () -> UserLocationRepository
        private let locationsRepositoryFactory: () -> LocationsRepository
        private let weatherRepositoryFactory: () -> WeatherRepository
        private let timeZoneRepositoryFactory: () -> TimeZoneRepository
        private var status: CLAuthorizationStatus
        private var userLocation: CLLocationCoordinate2D
        private var currentLocation: Location?
        private var weatherCache = [UUID: Weather]()
        private var searchResults = [Location]()
        var searchText = ""
        private var searchCancellable: AnyCancellable?
        
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
            
            status = userLocationAuthorisationRepositoryFactory().getAuthorisationStatus()
            userLocation = .init(latitude: .zero, longitude: .zero)
            
            if status != .notDetermined {
                refreshCurrentLocation(requestingAuthorisation: false)
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
        
        func refreshCurrentLocation(requestingAuthorisation requestAuthorisation: Bool) {
            let userLocationAuthorisationRepository = userLocationAuthorisationRepositoryFactory()
            let userLocationRepository = userLocationRepositoryFactory()
            let locationsRepository = locationsRepositoryFactory()
            let timeZoneRepository = timeZoneRepositoryFactory()
            let weatherRepository = weatherRepositoryFactory()
            
            Task {
                do {
                    let status = if requestAuthorisation {
                        await userLocationAuthorisationRepository.requestLocationAuthorisation()
                    } else {
                        userLocationAuthorisationRepository.getAuthorisationStatus()
                    }
                    
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
                            self.status = status
                            self.currentLocation = location
                            self.weatherCache[location.id] = weather
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        func update(_ location: Location) {
            let weatherRepository = weatherRepositoryFactory()
            let timeZoneRepository = timeZoneRepositoryFactory()
            
            Task {
                let coordinates = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                let weather = try await weatherRepository.getWeather(for: coordinates)
                let timeZone = try await timeZoneRepository.getTimeZone(at: coordinates)
                let location = Location(locationObject: location, timeZoneIdentifier: timeZone.name)
                
                await MainActor.run {
                    weatherCache[location.id] = weather
                    location.timeZone = timeZone.name
                }
            }
        }
        
        func search(for query: String) {
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
        
        private func performSearch(for query: String) {
            searchCancellable?.cancel()
            searchCancellable = Just(query)
                .debounce(for: .milliseconds(500),
                          scheduler: DispatchQueue.main
                )
                .sink { searchQuery in
                    self.search(for: searchQuery)
                }
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
        
        func weather(for location: Location) -> Weather? {
            weatherCache[location.id]
        }
        
        func getSearchResults() -> [Location] {
            searchResults
        }
    }
}
