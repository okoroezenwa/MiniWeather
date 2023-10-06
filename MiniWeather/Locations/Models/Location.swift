//
//  Location.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Location: Identifiable {
    let id = UUID()
    let timestamp: Date
    let city: String
    let state: String
    let country: String
    var nickname: String
    var note: String?
    let timezone: String
    
    init(city: String,
         state: String,
         country: String,
         nickname: String,
         note: String?,
         timezone: String
    ) {
        self.timestamp = .now
        self.city = city
        self.note = note
        self.timezone = timezone
        self.nickname = nickname
        self.state = state
        self.country = country
    }
    
    init(placemark: CLPlacemark) {
        self.timestamp = .now
        let city = placemark.name ?? "Unknown City"
        self.city = city
        self.nickname = city
        self.state = placemark.administrativeArea ?? "Unknown State"
        self.country = placemark.country ?? "Unknown Country"
        self.timezone = placemark.timeZone?.identifier ?? TimeZone.gmt.identifier
    }
}
