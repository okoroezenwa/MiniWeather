//
//  MockWeatherProvider.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import Foundation
@testable import MiniWeather
import CoreLocation

final class MockWeatherProvider: WeatherProvider {
    func getWeather<T>(for location: CLLocation) async throws -> T where T : WeatherProtocol {
        guard let weather = MockWeather() as? T else {
            throw TypeError.typeMismatch
        }
        return weather
    }
}
