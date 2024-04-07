//
//  FileDatastore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 01/04/2024.
//

import Foundation
import DiskCache
import OSLog

final class FileDatastore: Datastore {
    private let cache: Cache
    private let encoder: DataEncoder
    private let decoder: DataDecoder
    private let logger: Logger
    
    init(cache: Cache, encoder: DataEncoder, decoder: DataDecoder, logger: Logger) {
        self.cache = cache
        self.encoder = encoder
        self.decoder = decoder
        self.logger = logger
    }
    
    func fetch<Storable: Decodable>(forKey key: DatastoreKey) throws -> Storable {
        do {
            let data = try cache.syncData(key.rawValue)
            return try decoder.decode(Storable.self, from: data)
        } catch let error where error is DecodingError {
            throw error
        } catch {
            throw DatastoreError.notFound
        }
    }
    
    func store<Storable: Encodable>(_ storable: Storable, withKey key: DatastoreKey) throws {
        #warning("Use do-catch block")
        let data = try encoder.encode(storable)
        try cache.syncCache(data, key: key.rawValue)
    }
}
