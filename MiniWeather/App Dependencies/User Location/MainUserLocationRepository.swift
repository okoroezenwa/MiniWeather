//
//  MainUserLocationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation
import CoreLocation

struct MainUserLocationRepository: UserLocationRepository {
    private let userLocationProvider: UserLocationProvider
    
    init(userLocationProvider: UserLocationProvider) {
        self.userLocationProvider = userLocationProvider
    }
    
    func getUserLocation() async throws -> CLLocationCoordinate2D {
        try await userLocationProvider.getUserLocation()
    }
}
