//
//  UserLocationAuthorisationProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation
import CoreLocation

protocol UserLocationAuthorisationProvider {
    func getAuthorisationStatus() -> CLAuthorizationStatus
    func requestLocationAuthorisation() async -> CLAuthorizationStatus
}
