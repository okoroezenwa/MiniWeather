//
//  MainLocationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation

class MainLocationsRepository: LocationsRepository {
    private var geocodeService: GeocoderService
    
    init(geocodeService: GeocoderService) {
        self.geocodeService = geocodeService
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        try await geocodeService.retrieveLocations(named: searchText)
    }
}
