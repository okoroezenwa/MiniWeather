//
//  WeatherRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

/// An object that can return weather info.
protocol WeatherRepository {
    /**
     Gets weather information for the given coordinates.
     
     - Returns: The weather info for the given location coordinates.
     - Parameter location: The location to get weather info for.
     - Throws: A generic Error if unsuccessful.
     */
    func getWeather(for location: Location) async throws -> WeatherProtocol
}
