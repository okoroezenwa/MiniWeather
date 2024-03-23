//
//  MockUserLocationCoordinatesProvider.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 22/03/2024.
//

import Foundation
@testable import MiniWeather
import CoreLocation

final class MockUserLocationCoordinatesProvider: UserLocationCoordinatesProvider {
    let error: Error?
    
    init(error: Error? = nil) {
        self.error = error
    }
    
    func getUserLocationCoordinates() async throws -> CLLocationCoordinate2D {
        if let error {
            throw error
        }
        return .zero
    }
}
