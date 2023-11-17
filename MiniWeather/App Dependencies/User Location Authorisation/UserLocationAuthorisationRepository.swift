//
//  UserLocationAuthorisationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation
import CoreLocation

protocol UserLocationAuthorisationRepository {
    func getAuthorisationStatus() -> CLAuthorizationStatus
    func requestLocationAuthorisation() async -> CLAuthorizationStatus
}
