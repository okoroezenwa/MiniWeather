//
//  ViewModel.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import Foundation
import CoreLocation
import SwiftData
import Combine

@Observable class LocationsAdder {
    var searchString = ""
    var locations = [Location]()
    var locationsRepositoryFactory: () -> LocationsRepository
    var timeZoneRepositoryFactory: () -> TimeZoneRepository
    private var searchCancellable: AnyCancellable?
    
    init(locationsRepositoryFactory: @escaping () -> LocationsRepository,
         timeZoneRepositoryFactory: @escaping () -> TimeZoneRepository
    ) {
        self.locationsRepositoryFactory = locationsRepositoryFactory
        self.timeZoneRepositoryFactory = timeZoneRepositoryFactory
    }
    
    func add(_ location: Location, to modelContext: ModelContext) {
        modelContext.insert(location)
    }
    
    func search(for query: String) {
        guard query.count > 2 else {
            locations = []
            return
        }
        
        Task {
            let locationsRepository = locationsRepositoryFactory()
            let locations = try await locationsRepository.getLocations(named: query)
            
            await MainActor.run {
                self.locations = locations
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
    
    func getNewLocationWithUpdatedTimeZone(for location: Location) async throws -> Location {
        let timeZoneRepository = timeZoneRepositoryFactory()
        let coordinates = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        let identifier = try await timeZoneRepository.getTimeZone(at: coordinates)
        return Location(city: location.city, state: location.state, country: location.country, nickname: location.nickname, note: location.note, timeZone: identifier.name, latitide: location.latitude, longitude: location.longitude)
    }
}
