//
//  GeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation
import CoreLocation

protocol GeocoderService {
    func getLocations(named searchText: String) async throws -> [Location]
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location]
}
