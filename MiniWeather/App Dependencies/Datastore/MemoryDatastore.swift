//
//  MemoryDatastore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/11/2023.
//

import Foundation
import OSLog

/// Needs work.
struct MemoryDatastore: Datastore {
    private var store: TemporaryStore
    private let logger: Logger
    
    init(store: TemporaryStore, logger: Logger) {
        self.store = store
        self.logger = logger
    }
    
    func fetch<Storable>(forKey key: DatastoreKey) throws -> Storable where Storable : Decodable {
        guard let object = store.value(forKey: key) as? Storable else {
            throw DatastoreError.notFound
        }
        
        return object
    }
    
    func store<Storable>(_ storable: Storable, withKey key: DatastoreKey) throws where Storable : Encodable {
        store.set(storable, forKey: key)
    }
}

final class TemporaryStore {
    private lazy var dictionary = [DatastoreKey: Any]()
    
    func value(forKey key: DatastoreKey) -> Any? {
        dictionary[key]
    }
    
    func set(_ value: Any, forKey key: DatastoreKey) {
        dictionary[key] = value
    }
}
