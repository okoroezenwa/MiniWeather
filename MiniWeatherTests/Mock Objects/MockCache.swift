//
//  MockCache.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 04/04/2024.
//

import Foundation
@testable import MiniWeather
import DiskCache

typealias VoidUnsafeContinuation = UnsafeContinuation<Void, Error>

final class MockCache: Cache {
    private var store: [String: Data]?
    
    init(store: [String : Data]?) {
        self.store = store
    }
    
    func syncCache(_ data: Data, key: String) throws {
        guard var store else {
            throw DatastoreError.notFound
        }
        store[key] = data
    }
    
    func syncData(_ key: String) throws -> Data {
        guard let store else {
            throw DatastoreError.notFound
        }
        
        guard let data = store[key] else {
            throw DatastoreError.notFound
        }
        
        return data
    }
    
    func syncDelete(_ key: String) throws {
        guard var store else {
            throw DatastoreError.notFound
        }
        store[key] = nil
    }
    
    func syncDeleteAll() throws {
        guard let _ = store else {
            throw DatastoreError.notFound
        }
        store = [:]
    }
    
    func fileURL(_ key: String) -> URL {
        URL.cachesDirectory
    }
    
    func cache(_ data: Data, key: String) async throws {
        try await withUnsafeThrowingContinuation { (continuation: VoidUnsafeContinuation) -> Void in
            do {
                try syncCache(data, key: key)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func data(_ key: String) async throws -> Data {
        try await withUnsafeThrowingContinuation { continuation -> Void in
            do {
                let data = try syncData(key)
                continuation.resume(returning: data)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func delete(_ key: String) async throws {
        try await withUnsafeThrowingContinuation { (continuation: VoidUnsafeContinuation) -> Void in
            do {
                try syncDelete(key)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func deleteAll() async throws {
        try await withUnsafeThrowingContinuation { (continuation: VoidUnsafeContinuation) -> Void in
            do {
                try syncDeleteAll()
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
