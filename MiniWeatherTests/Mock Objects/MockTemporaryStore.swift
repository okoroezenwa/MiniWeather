//
//  MockTemporaryStore.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 03/04/2024.
//

import Foundation
@testable import MiniWeather

final class MockTemporaryStore: TemporaryStore {
    private var dictionary: [DatastoreKey: Any]
    
    init(dictionary: [DatastoreKey : Any]) {
        self.dictionary = dictionary
    }
    
    func value(forKey key: DatastoreKey) -> Any? {
        dictionary[key]
    }
    
    func set(_ value: Any, forKey key: DatastoreKey) {
        dictionary[key] = value
    }
}
