//
//  LocationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation

protocol LocationsRepository {
    func getLocations(named searchText: String) async throws -> [Location]
}
