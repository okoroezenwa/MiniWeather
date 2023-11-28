//
//  Datastore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/11/2023.
//

import Foundation

/// An object that can store and retrieve an object locally.
protocol Datastore {
    /**
     Retrieves a stored object from disk storage.
     
     - Returns: The Storable object requested.
     - Parameter key: The key used to obtain the stored object.
     - Throws: A DecodingError if unsuccessful.
     */
    func fetch<Storable: Decodable>(forKey key: DatastoreKey) throws -> Storable
    
    /**
     Stores the given object to disk.
     
     - Parameters:
        - object: The Storable object to store.
        - key: The key to be used to identify the object.
     */
    func store<Storable: Encodable>(_ storable: Storable, withKey key: DatastoreKey) throws
}

enum DatastoreKey: RawRepresentable, Hashable {
    case savedLocations
    case timeZone(name: String)
    case currentLocation
    
    init?(rawValue: String) {
        switch rawValue {
            case "locations": 
                self = .savedLocations
            case let x where x.hasPrefix("timeZone"): 
                self = .timeZone(name: x.replacingOccurrences(of: "timeZone", with: ""))
            case "currentLocation":
                self = .currentLocation
            default:
                return nil
        }
    }
    
    var rawValue: String {
        switch self {
            case .savedLocations: 
                return "locations"
            case .timeZone(name: let fullName): 
                return "timeZone+\(fullName)"
            case .currentLocation:
                return "currentLocation"
        }
    }
}
