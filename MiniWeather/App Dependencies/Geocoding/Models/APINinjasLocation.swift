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
    
    init(tempLocation: APINinjasTemporaryLocation, coordinates: CLLocationCoordinate2D) {
        self.city = tempLocation.city
        self.state = tempLocation.state
        self.country = tempLocation.country
        self.longitude = coordinates.longitude
        self.latitude = coordinates.latitude
    }
    
    let city: String
    let latitude: Double
    let longitude: Double
    let country: String
    let state: String?
}

struct APINinjasTemporaryLocation: Decodable {
    enum CodingKeys: String, CodingKey {
        case city = "name"
        case state
        case country
    }
    
    let city: String
    let country: String
    let state: String?
}

extension APINinjasLocation {
    var countryName: String {
        CountryCodes(rawValue: country)?.country ?? "Unknown Country"
    }
}
