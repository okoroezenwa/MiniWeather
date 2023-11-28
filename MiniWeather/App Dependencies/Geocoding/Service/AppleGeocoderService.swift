//
//  AppleGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation
import CoreLocation

struct AppleGeocoderService: GeocoderService {
    func getLocations(named searchText: String) async throws -> [Location] {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(searchText)
            return placemarks.map { Location(locationObject: $0, timeZoneIdentifier: $0.timeZone?.identifier ?? "") }
        } catch let error {
            throw error
        }
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                .init(latitude: coordinates.latitude, longitude: coordinates.longitude)
            )
            return placemarks.map { Location(locationObject: $0, timeZoneIdentifier: $0.timeZone?.identifier ?? "") }
        } catch let error {
            throw error
        }
    }
}
