//
//  UserLocationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 15/11/2023.
//

import Foundation
import CoreLocation

/// An object that can return the user's current location coordinates.
protocol UserLocationRepository {
    /**
     Returns the user's current location coordinates.
     
     - Returns: The user's current location coordinates..
     - Throws: CLError.Code.locationUnknown if unable to retrieve a location right away, CLError.Code.headingFailure if failure is caused by strong magnetic winds, or CLError.Code.denied if the user has denied location services to the app.
     */
    func getUserLocation() async throws -> CLLocationCoordinate2D
}
