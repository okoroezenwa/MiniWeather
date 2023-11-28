//
//  Location.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import Foundation
import CoreLocation

protocol LocationProtocol {
    var city: String { get }
    var state: String? { get }
    var countryName: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
}

/// The Location object.
struct Location: Codable, Identifiable, Hashable {
    let id: UUID
    let timestamp: Date
    let city: String
    let state: String?
    let country: String
    var nickname: String
    var timeZone: String
    let longitude: Double
    let latitude: Double
    
    init(id: UUID = UUID(),
         timestamp: Date = .now,
         city: String,
         state: String?,
         country: String,
         nickname: String,
         timeZone: String,
         latitide: Double,
         longitude: Double
    ) {
        self.id = id
        self.timestamp = timestamp
        self.city = city
        self.timeZone = timeZone
        self.nickname = nickname
        self.state = state
        self.country = country
        self.longitude = longitude
        self.latitude = latitide
    }
    
    init<LocationObject: LocationProtocol>(locationObject: LocationObject, timeZoneIdentifier: String) {
        let city = locationObject.city
        self.city = city
        self.nickname = city
        self.state = locationObject.state
        self.country = locationObject.countryName
        self.latitude = locationObject.latitude
        self.longitude = locationObject.longitude
        self.timeZone = timeZoneIdentifier
        self.id = UUID()
        self.timestamp = .now
    }
}

extension Location: LocationProtocol {
    var countryName: String {
        country
    }
    
    var fullName: String {
        var name = city
        
        if let state {
            name += ", \(state)"
        }
        
        name += ", \(country)"
        
        return name
    }
}

// Convenience functions for Location
extension Location {
    var actualTimeZone: TimeZone {
        return TimeZone(identifier: timeZone) ?? .autoupdatingCurrent
    }
    
    func currentDateString(with formatter: DateFormatter) -> String {
        formatter.timeZone = actualTimeZone
        return formatter.string(from: Date.now)
    }
    
    func isOutdated() -> Bool {
        guard let fifteenAfter = Calendar.autoupdatingCurrent.date(byAdding: .minute, value: 15, to: timestamp), Date.now > fifteenAfter else {
            return false
        }
        return true
    }
    
    func coordinates() -> CLLocationCoordinate2D {
        .init(
            latitude: latitude,
            longitude: longitude
        )
    }
}
