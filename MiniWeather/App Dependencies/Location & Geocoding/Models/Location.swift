//
//  Location.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import Foundation
import SwiftData

protocol LocationProtocol {
    var city: String { get }
    var state: String? { get }
    var countryName: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
}

@Model
final class Location: Identifiable, LocationProtocol {
    let id = UUID()
    let timestamp = Date.now
    let city: String
    let state: String?
    let country: String
    var nickname: String
    var note: String?
    var timeZone: String
    let longitude: Double
    let latitude: Double
    
    init(city: String,
         state: String?,
         country: String,
         nickname: String,
         note: String?,
         timeZone: String,
         latitide: Double,
         longitude: Double
    ) {
        self.city = city
        self.note = note
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
    }
}

extension Location {
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
    
    var actualTimeZone: TimeZone {
        return TimeZone(identifier: timeZone) ?? .gmt
    }
    
    func currentDateString(with formatter: DateFormatter) -> String {
        formatter.timeZone = actualTimeZone
        return formatter.string(from: Date.now)
    }
}
