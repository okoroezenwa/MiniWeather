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
        - key: The key used to identify the object.
     */
    func store<Storable: Encodable>(_ storable: Storable, withKey key: DatastoreKey) throws
}

enum DatastoreKey: RawRepresentable, Hashable {
    case savedItems
    case timeZone(name: String)
    case currentLocation
    case records
    case syncEngineState
    
    init?(rawValue: String) {
        switch rawValue {
            case "locations": 
                self = .savedItems
            case let x where x.hasPrefix("timeZone"): 
                self = .timeZone(name: x.replacingOccurrences(of: "timeZone", with: ""))
            case "currentLocation":
                self = .currentLocation
            case "records":
                self = .records
            case "syncEngineState":
                self = .syncEngineState
            default:
                return nil
        }
    }
    
    var rawValue: String {
        switch self {
            case .savedItems: 
                return "locations"
            case .timeZone(name: let fullName): 
                return "timeZone+\(fullName)"
            case .currentLocation:
                return "currentLocation"
            case .records:
                return "records"
            case .syncEngineState:
                return "syncEngineState"
        }
    }
}
