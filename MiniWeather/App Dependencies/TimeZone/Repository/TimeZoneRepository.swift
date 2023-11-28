//
//  TimeZoneRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

/// An object that can return a time zone for a location's coordinates.
protocol TimeZoneRepository {
    /**
     Obtains the time zone for a given set of coordinates.
     
     - Returns: The requested time zone as a TimeZoneIdentifier object.
     - Parameter location: The location to get the time zone for.
     - Throws: A generic Error if unsuccessful.
     */
    func getTimeZone(for location: Location) async throws -> TimeZoneIdentifier
}
