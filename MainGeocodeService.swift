//
//  MainGeocodeService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation
import CoreLocation

struct MainGeocodeService: GeocodeService {
    
    init() {
        
    }
    
    func retrieveLocations(named searchText: String) async throws -> [Location] {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(searchText)
            return placemarks.map { Location.init(placemark: $0) }
        } catch let error {
            throw error
        }
    }
}
