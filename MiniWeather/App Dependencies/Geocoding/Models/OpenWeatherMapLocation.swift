//
//  OpenWeatherMapLocation.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapLocation: Decodable, LocationProtocol {
    enum CodingKeys: String, CodingKey {
        case city = "name"
        case state
        case country
        case longitude = "lon"
        case latitude = "lat"
    }
    
    let city: String
    let latitude: Double
    let longitude: Double
    let country: String
    let state: String?
}

extension OpenWeatherMapLocation {
    var countryName: String {
        CountryCodes(rawValue: country)?.country ?? "Unknown Country"
    }
}
