//
//  APINinjasLocation.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

/// The API-Ninjas location object.
struct APINinjasLocation: Decodable, LocationProtocol {
    enum CodingKeys: String, CodingKey {
        case city = "name"
        case state
        case country
        case longitude
        case latitude
    }
    
    init(tempLocation: PartialLocationProtocol, coordinates: CLLocationCoordinate2D) {
        self.city = tempLocation.city
        self.state = tempLocation.state
        self.country = tempLocation.countryName
        self.longitude = coordinates.longitude
        self.latitude = coordinates.latitude
    }
    
    let city: String
    let latitude: Double
    let longitude: Double
    let country: String
    let state: String?
}

struct APINinjasTemporaryLocation: Decodable, PartialLocationProtocol {
    enum CodingKeys: String, CodingKey {
        case city = "name"
        case state
        case country
    }
    
    let city: String
    let country: String
    let state: String?
    var countryName: String { country }
}

extension APINinjasLocation {
    var countryName: String {
        CountryCodes(rawValue: country)?.country ?? "Unknown Country"
    }
}
