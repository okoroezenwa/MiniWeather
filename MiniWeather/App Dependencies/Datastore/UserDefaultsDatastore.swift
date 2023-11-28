//
//  UserDefaultsDatastore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/11/2023.
//

import Foundation
import OSLog

struct UserDefaultsDatastore: Datastore {
    private let store: KeyValueStore
    private let decoder: DataDecoder
    private let encoder: DataEncoder
    private let logger: Logger
    
    init(store: KeyValueStore, decoder: DataDecoder, encoder: DataEncoder, logger: Logger) {
        self.store = store
        self.decoder = decoder
        self.encoder = encoder
        self.logger = logger
    }
    
    func fetch<Storable>(forKey key: DatastoreKey) throws -> Storable where Storable : Decodable {
        guard let data = store.data(forKey: key.rawValue) else {
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
    
    func store<Storable>(_ storable: Storable, withKey key: DatastoreKey) throws where Storable : Encodable {
        do {
            let data = try encoder.encode(storable)
            store.set(data, forKey: key.rawValue)
        } catch {
            
        }
    }
}

enum DatastoreError: Error {
    case notFound
    case failedDecode
    case failedSynchronise
}
