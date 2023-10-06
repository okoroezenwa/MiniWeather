//
//  GeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation

protocol GeocodeService {
    func retrieveLocations(named searchText: String) async throws -> [Location]
}
