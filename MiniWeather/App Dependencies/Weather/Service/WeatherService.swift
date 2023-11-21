//
//  WeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

/// An object that interfaces with a web API to retrieve weather info.
protocol WeatherService {
    /**
     Gets weather information for the given coordinates.
     
     - Returns: The weather info for the given location coordinates.
     - Parameter coordinates: The coordinates to get weather info for.
     - Throws: A generic Error if unsuccessful.
     */
    func getWeather(at coordinates: CLLocationCoordinate2D) async throws -> Weather
}
