//
//  AppleGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation
import CoreLocation

struct AppleGeocoderService<T: TimeZoneLocationProtocol>: GeocoderService {
    private let geocoder: TimeZoneLocationGeocoder
    
    init(geocoder: TimeZoneLocationGeocoder) {
        self.geocoder = geocoder
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        do {
            let placemarks: [T] = try await geocoder.getLocations(named: searchText)
            return placemarks.map { Location(locationObject: $0, timeZone: .init(timeZone: $0.timeZone)) }
        } catch let error {
            throw error
        }
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        do {
            let placemarks: [T] = try await geocoder.getLocations(at: .init(latitude: coordinates.latitude, longitude: coordinates.longitude))
            return placemarks.map { Location(locationObject: $0, timeZone: .init(timeZone: $0.timeZone)) }
        } catch let error {
            throw error
        }
    }
}
