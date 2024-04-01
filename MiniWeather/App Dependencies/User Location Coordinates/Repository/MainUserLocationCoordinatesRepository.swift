//
//  MainUserLocationCoordinatesRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation
import CoreLocation

struct MainUserLocationCoordinatesRepository: UserLocationCoordinatesRepository {
    private let userLocationProvider: UserLocationCoordinatesProvider
    
    init(userLocationProvider: UserLocationCoordinatesProvider) {
        self.userLocationProvider = userLocationProvider
    }
    
    func getUserLocationCoordinates() async throws -> CLLocationCoordinate2D {
        try await userLocationProvider.getUserLocationCoordinates()
    }
}
