//
//  CLPlacemark+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

extension CLPlacemark: TimeZoneLocationProtocol {
    var city: String {
        locality ?? name ?? "Unknown City"
    }
    
    var state: String? {
        administrativeArea
    }
    
    var countryName: String {
        country ?? "Unknown Country"
    }
    
    var latitude: Double {
        location?.coordinate.latitude ?? 0
    }
    
    var longitude: Double {
        location?.coordinate.longitude ?? 0
    }
}
