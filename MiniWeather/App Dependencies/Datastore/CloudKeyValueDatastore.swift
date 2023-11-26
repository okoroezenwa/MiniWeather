//
//  CloudKeyValueDatastore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/11/2023.
//

import Foundation
import OSLog

struct CloudKeyValueDatastore: Datastore {
    private let store: KeyValueStore
    private let decoder: DataDecoder
    private let encoder: DataEncoder
    private let localStorage: KeyValueStore
    private let logger: Logger
    
    init(store: KeyValueStore, decoder: DataDecoder, encoder: DataEncoder, localStorage: KeyValueStore, logger: Logger) {
        self.store = store
        self.decoder = decoder
        self.encoder = encoder
        self.localStorage = localStorage
        self.logger = logger
    }
    
    func fetch<Storable: Decodable>(forKey key: DatastoreKey) throws -> Storable {
        guard let data = localStorage.data(forKey: key.rawValue) else {
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
            localStorage.set(data, forKey: key.rawValue)
            store.set(data, forKey: key.rawValue)
            
            let isSuccessful = store.synchronize()
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

protocol KeyValueStore {
    func data(forKey: String) -> Data?
    func set(_ value: Any?, forKey: String)
    func synchronize() -> Bool
}

protocol DataDecoder {
    func decode<Object>(_ type: Object.Type, from data: Data) throws -> Object where Object : Decodable
}

protocol DataEncoder {
    func encode<Object: Encodable>(_ object: Object) throws -> Data
}

extension JSONDecoder: DataDecoder { }

extension JSONEncoder: DataEncoder { }

extension UserDefaults: KeyValueStore { }

extension NSUbiquitousKeyValueStore: KeyValueStore { }
