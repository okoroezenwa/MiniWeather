//
//  UserLocationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 15/11/2023.
//

import Foundation
import CoreLocation

protocol UserLocationRepository {
    func getUserLocation() async throws -> CLLocationCoordinate2D
}
