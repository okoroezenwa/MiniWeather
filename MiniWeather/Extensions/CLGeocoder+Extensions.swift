//
//  CLGeocoder+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
import CoreLocation

extension CLGeocoder: TimeZoneLocationGeocoder {
    func getLocations<T>(at coordinates: CLLocationCoordinate2D) async throws -> [T] where T : TimeZoneLocationProtocol {
        let placemarks = try await reverseGeocodeLocation(.init(latitude: coordinates.latitude, longitude: coordinates.longitude))
        
        guard let locations = placemarks as? [T] else {
            throw TypeError.typeMismatch
        }
        
        return locations
    }
    
    func getLocations<T>(named searchText: String) async throws -> [T] where T : TimeZoneLocationProtocol {
        let placemarks = try await geocodeAddressString(searchText)
        
        guard let locations = placemarks as? [T] else {
            throw TypeError.typeMismatch
        }
        
        return locations
    }
}

#warning("Organise later")
enum TypeError: Error {
    case typeMismatch
}
