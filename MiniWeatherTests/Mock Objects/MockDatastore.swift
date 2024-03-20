//
//  MockDatastore.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import Foundation
@testable import MiniWeather

final class MockDatastore: Datastore {
    private var dict: [DatastoreKey: Any]
    
    init(dict: [DatastoreKey : Any]) {
        self.dict = dict
    }
    
    func fetch<Storable>(forKey key: MiniWeather.DatastoreKey) throws -> Storable where Storable : Decodable {
        guard let item = dict[key] else {
            throw DatastoreError.notFound
        }
        
        guard let storable = dict[key] as? Storable else {
            throw TypeError.typeMismatch
        }
        
        return storable
    }
    
    func store<Storable>(_ storable: Storable, withKey key: MiniWeather.DatastoreKey) throws where Storable : Encodable {
        dict[key] = storable
    }
}
