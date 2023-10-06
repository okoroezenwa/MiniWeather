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
    var locationsRepository: LocationsRepository
    private var searchCancellable: AnyCancellable?
    
    init(locationsRepository: LocationsRepository) {
        self.locationsRepository = locationsRepository
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
            let locations = try await locationsRepository.getLocations(named: query)
            
            await MainActor.run {
                self.locations = locations
            }
        }
    }
    
    private func performSearch(for query: String) {
        searchCancellable?.cancel()
        searchCancellable = Just(query)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { searchQuery in
                self.search(for: searchQuery)
            }
    }
}
