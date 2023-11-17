//
//  UserLocationProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation
import CoreLocation

protocol UserLocationProvider {
    func getUserLocation() async throws -> CLLocationCoordinate2D
}
