//
//  MockTimeZoneLocationGeocoder.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 19/03/2024.
//

import Foundation
import CoreLocation
@testable import MiniWeather

struct MockTimeZoneLocationGeocoder: TimeZoneLocationGeocoder {
    func getLocations<T>(named searchText: String) async throws -> [T] where T : MiniWeather.TimeZoneLocationProtocol {
        guard let locations = [MockTimeZoneLocation()] as? [T] else {
            throw TypeError.typeMismatch
        }
        return locations
    }
    
    func getLocations<T>(at coordinates: CLLocationCoordinate2D) async throws -> [T] where T : MiniWeather.TimeZoneLocationProtocol {
        guard let locations = [MockTimeZoneLocation()] as? [T] else {
            throw TypeError.typeMismatch
        }
        return locations
    }
}
