//
//  APINinjaLocation.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

struct APINinjaLocation: Decodable, LocationProtocol {
    enum Keys: String, CodingKey {
        case city = "name"
        case state
        case countryName = "country"
        case longitude
        case latitude
    }
    
    let city: String
    let latitude: Double
    let longitude: Double
    let countryName: String
    let state: String
}
