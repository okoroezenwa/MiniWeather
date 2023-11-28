//
//  UserLocationAuthorisationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation
import CoreLocation

/// An object that can return the user's authorisation status and the result of the first.
protocol UserLocationAuthorisationRepository {
    /**
    Immediately returns the system's current location authorisation staus.
     
    - Returns: The current authorisation status from the system.
     */
    func getAuthorisationStatus() -> CLAuthorizationStatus
    
    /**
     Requests location authorisation and returns the result of the user's decision.
     
     - Returns: The authorisation status the user has chosen.
     */
    func requestLocationAuthorisation() async -> CLAuthorizationStatus
}
