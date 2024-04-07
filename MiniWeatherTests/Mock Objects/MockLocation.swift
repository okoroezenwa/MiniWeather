//
//  MockLocation.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
@testable import MiniWeather

struct MockLocation: LocationProtocol, Codable {
    var city: String = "Abuja"
    var state: String? = "FCT"
    var countryName: String = "Nigeria"
    var latitude: Double = 0
    var longitude: Double = 0
}

extension MockLocation: Equatable { }
