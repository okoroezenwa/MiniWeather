//
//  MainLocationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation

struct MainLocationsRepository: LocationsRepository {
    private var geocodeService: GeocodeService
    
    init(geocodeService: GeocodeService) {
        self.geocodeService = geocodeService
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        try await geocodeService.retrieveLocations(named: searchText)
    }
}
