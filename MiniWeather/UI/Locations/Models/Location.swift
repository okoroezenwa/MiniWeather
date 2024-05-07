//
//  Location.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import CoreLocation
import SwiftUI
import CloudKit

/// The Location object.
struct Location: Identifiable, Hashable, Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case city
        case state
        case country
        case position
        case nickname
        case timeZoneIdentifier
        case longitude
        case latitude
    }
    
    let id: String
    let timestamp: Date
    let city: String
    let state: String?
    let country: String
    var position: Int
    var nickname: String
    var timeZoneIdentifier: TimeZoneIdentifier?
    let longitude: Double
    let latitude: Double
    var lastModified = Date.distantPast
    
    static let zoneName = "Locations"
    static let recordType = "Location"
    
    init(id: String = UUID().uuidString,
         timestamp: Date = .now,
         city: String,
         state: String?,
         country: String,
         position: Int = 0,
         nickname: String,
         timeZone: TimeZoneIdentifier?,
         latitide: Double,
         longitude: Double
    ) {
        self.id = id
        self.timestamp = timestamp
        self.city = city
        self.timeZoneIdentifier = timeZone
        self.nickname = nickname
        self.state = state
        self.country = country
        self.longitude = longitude
        self.latitude = latitide
        self.position = position
    }
    
    init<LocationObject: LocationProtocol>(locationObject: LocationObject, timeZone: TimeZoneIdentifier?) {
        let city = locationObject.city
        self.city = city
        self.nickname = (locationObject as? Location)?.nickname ?? city
        self.state = locationObject.state
        self.country = locationObject.countryName
        self.latitude = locationObject.latitude
        self.longitude = locationObject.longitude
        self.timeZoneIdentifier = timeZone
        self.id = UUID().uuidString
        self.timestamp = .now
        self.position = 0
    }
}

extension Location: LocationProtocol {
    nonisolated var countryName: String {
        country
    }
    
    nonisolated var fullName: String {
        var name = city
        
        if let state {
            name += ", \(state)"
        }
        
        name += ", \(country)"
        
        return name
    }
}

extension Location: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .location)
    }
}

extension Location: CloudKitModel {
    var recordFields: [(kind: CKRecord.FieldKey.Kind, value: CKRecordValueProtocol?)] {
        [
            (.unencrypted(.city), city),
            (.unencrypted(.nickname), nickname),
            (.unencrypted(.state), state),
            (.unencrypted(.country), country),
            (.unencrypted(.latitude), latitude),
            (.unencrypted(.longitude), longitude),
            (.unencrypted(.timestamp), timestamp),
            (.unencrypted(.position), position),
            (.unencrypted(.timeZoneIdentifier), timeZoneIdentifier?.name),
            (.unencrypted(.timeZoneOffset), timeZoneIdentifier?.offset),
            (.unencrypted(.lastModified), lastModified)
        ]
    }
}

// Convenience functions for Location
extension Location {
    var actualTimeZone: TimeZone {
        return {
            if let offset = timeZoneIdentifier?.offset, let timeZone = TimeZone(secondsFromGMT: offset) {
                return timeZone
            } else {
                return TimeZone(identifier: timeZoneIdentifier?.name ?? "") ?? .autoupdatingCurrent
            }
        }()
    }
    
    func currentDateString(with formatter: DateFormatter) -> String {
        guard let timeZone: TimeZone = {
            if let offset = timeZoneIdentifier?.offset {
                return TimeZone(secondsFromGMT: offset)
            } else {
                return TimeZone(identifier: timeZoneIdentifier?.name ?? "")
            }
        }() else {
            return "--:--"
        }
        
        formatter.timeZone = timeZone
        return formatter.string(from: Date.now)
    }
    
    func isOutdated() -> Bool {
        guard let fifteenAfter = Calendar.autoupdatingCurrent.date(byAdding: .minute, value: 15, to: timestamp), Date.now > fifteenAfter else {
            return false
        }
        return true
    }
}

extension Location {
    static let toastMessageAttributeValues: [AttributedString.AttributeValue] = [.foreground(.primary), .font(.system(size: 13, weight: .semibold))]
}
