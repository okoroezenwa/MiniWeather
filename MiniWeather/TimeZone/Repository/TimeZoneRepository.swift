//
//  TimeZoneRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

protocol TimeZoneRepository {
    func getTimeZone(at coordinates: CLLocationCoordinate2D) async throws -> TimeZoneIdentifier
}
