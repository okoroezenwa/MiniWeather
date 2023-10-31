//
//  WeatherService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation
import CoreLocation

protocol WeatherService {
    func getWeather(at coordinates: CLLocationCoordinate2D) async throws -> Weather
}
