//
//  MainLocationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation
import CoreLocation

struct MainLocationsRepository: LocationsRepository {
    private var geocodeService: GeocoderService
    
    init(geocodeService: GeocoderService) {
        self.geocodeService = geocodeService
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        try await geocodeService.getLocations(named: searchText)
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        try await geocodeService.getLocations(at: coordinates)
    }
}
