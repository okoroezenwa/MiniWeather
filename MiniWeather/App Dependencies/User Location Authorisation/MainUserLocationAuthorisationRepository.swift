//
//  MainUserLocationAuthorisationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation
import CoreLocation

class MainUserLocationAuthorisationRepository: UserLocationAuthorisationRepository {
    private let userLocationAuthorisationProvider: UserLocationAuthorisationProvider
    
    init(userLocationAuthorisationProvider: UserLocationAuthorisationProvider) {
        self.userLocationAuthorisationProvider = userLocationAuthorisationProvider
    }
    
    func getAuthorisationStatus() -> CLAuthorizationStatus {
        userLocationAuthorisationProvider.getAuthorisationStatus()
    }
    
    func requestLocationAuthorisation() async -> CLAuthorizationStatus {
        await userLocationAuthorisationProvider.requestLocationAuthorisation()
    }
}
