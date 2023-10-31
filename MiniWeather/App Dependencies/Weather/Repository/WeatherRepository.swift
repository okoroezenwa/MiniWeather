//
//  WeatherRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

protocol WeatherRepository {
    func getWeather(for coordinates: CLLocationCoordinate2D) async throws -> Weather
}
