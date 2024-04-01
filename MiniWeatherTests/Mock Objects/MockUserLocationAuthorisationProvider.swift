//
//  MockUserLocationAuthorisationProvider.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 22/03/2024.
//

import Foundation
@testable import MiniWeather
import CoreLocation

final class MockUserLocationAuthorisationProvider: UserLocationAuthorisationProvider {
    private let status: CLAuthorizationStatus
    
    init(status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func getAuthorisationStatus() -> CLAuthorizationStatus {
        status
    }
    
    func requestLocationAuthorisation() async -> CLAuthorizationStatus {
        status
    }
    
    
}
