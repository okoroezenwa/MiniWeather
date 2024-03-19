//
//  MockTimeZoneLocation.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
@testable import MiniWeather

struct MockTimeZoneLocation: TimeZoneLocationProtocol, Decodable {
    var city: String = "Abuja"
    var state: String? = "FCT"
    var countryName: String = "Nigeria"
    var latitude: Double = 0
    var longitude: Double = 0
    var timeZone: TimeZone? = .gmt
}
