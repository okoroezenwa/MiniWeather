//
//  CurrentLocationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation

protocol CurrentLocationRepository {
    func getCurrentLocation() throws -> Location
}
