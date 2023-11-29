//
//  CloudKeyValueDatastore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/11/2023.
//

import Foundation
import OSLog

struct CloudKeyValueDatastore: Datastore {
    private let cloudStore: KeyValueStore
    private let localStore: KeyValueStore
    private let decoder: DataDecoder
    private let encoder: DataEncoder
    private let logger: Logger
    
    init(cloudStore: KeyValueStore, localStore: KeyValueStore, decoder: DataDecoder, encoder: DataEncoder, logger: Logger) {
        self.cloudStore = cloudStore
        self.localStore = localStore
        self.decoder = decoder
        self.encoder = encoder
        self.logger = logger
    }
    
    func fetch<Storable: Decodable>(forKey key: DatastoreKey) throws -> Storable {
        guard let data = localStore.data(forKey: key.rawValue) else {
            throw DatastoreError.notFound
        }
        
        do {
            let storable = try decoder.decode(Storable.self, from: data)
            logger.debug("Obtained saved item of type \(Storable.Type.self)")
            return storable
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    func store<Storable: Encodable>(_ storable: Storable, withKey key: DatastoreKey) throws {
        do {
            let data = try encoder.encode(storable)
            localStore.set(data, forKey: key.rawValue)
            cloudStore.set(data, forKey: key.rawValue)
            
            let isSuccessful = cloudStore.synchronize()
            if !isSuccessful {
                logger.error("NSUbiqiousKeyValueStore synchronisation failed")
                throw DatastoreError.failedSynchronise
            }
        } catch {
            logger.error("Failed to save item of type \(Storable.Type.self)")
            throw error
        }
    }
}

extension NSNotification.Name {
    static let cloudStoreUpdated = NSNotification.Name.init("cloudStoreUpdated")
}
