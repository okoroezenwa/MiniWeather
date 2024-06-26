//
//  MockDatastore.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import Foundation
@testable import MiniWeather

final class MockDatastore: Datastore {
    #warning("Replace nullability with encoder/decoder?")
    private var dict: [DatastoreKey: Any]?
    
    init(dict: [DatastoreKey : Any]?) {
        self.dict = dict
    }
    
    func fetch<Storable>(forKey key: MiniWeather.DatastoreKey) throws -> Storable where Storable : Decodable {
        guard let dict else {
            throw LocationError.notFound
        }
        
        guard let item = dict[key] else {
            throw DatastoreError.notFound
        }
        
        guard let storable = item as? Storable else {
            throw TypeError.typeMismatch
        }
        
        return storable
    }
    
    func store<Storable>(_ storable: Storable, withKey key: MiniWeather.DatastoreKey) throws where Storable : Encodable {
        dict?[key] = storable
    }
}
