//
//  AppleGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation
import CoreLocation

struct AppleGeocoderService: GeocoderService {
    #warning("Make a protocol for this")
    private let geocoder: CLGeocoder
    
    init(geocoder: CLGeocoder) {
        self.geocoder = geocoder
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        do {
            let placemarks = try await geocoder.geocodeAddressString(searchText)
            return placemarks.map { Location(locationObject: $0, timeZone: .init(timeZone: $0.timeZone)) }
        } catch let error {
            throw error
        }
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                .init(latitude: coordinates.latitude, longitude: coordinates.longitude)
            )
            return placemarks.map { Location(locationObject: $0, timeZone: .init(timeZone: $0.timeZone)) }
        } catch let error {
            throw error
        }
    }
}
