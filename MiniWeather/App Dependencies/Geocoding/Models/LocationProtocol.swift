//
//  LocationProtocol.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
import CoreLocation

/// The protocol to which all Location objects conform.
protocol LocationProtocol {
    var city: String { get }
    var state: String? { get }
    var countryName: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
}

extension LocationProtocol {
    func coordinates() -> CLLocationCoordinate2D {
        .init(
            latitude: latitude,
            longitude: longitude
        )
    }
}

protocol PartialLocationProtocol {
    var city: String { get }
    var state: String? { get }
    var countryName: String { get }
}

protocol TimeZoneLocationProtocol: LocationProtocol {
    var timeZone: TimeZone? { get }
}

protocol TimeZoneLocationGeocoder {
    func getLocations<T: TimeZoneLocationProtocol>(named searchText: String) async throws -> [T]
    func getLocations<T: TimeZoneLocationProtocol>(at coordinates: CLLocationCoordinate2D) async throws -> [T]
}
