//
//  MemoryDatastore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/11/2023.
//

import Foundation
import OSLog

/// Needs work.
final class MemoryDatastore: Datastore {
    private var store: [DatastoreKey: Any]
    private let logger: Logger
    
    init(store: [DatastoreKey : Any], logger: Logger) {
        self.store = store
        self.logger = logger
    }
    
    func fetch<Storable>(forKey key: DatastoreKey) throws -> Storable where Storable : Decodable {
        guard let object = store[key] as? Storable else {
            throw DatastoreError.notFound
        }
        
        return object
    }
    
    func store<Storable>(_ storable: Storable, withKey key: DatastoreKey) throws where Storable : Encodable {
        store[key] = storable
    }
}
