//
//  StandardTemporaryStore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 02/04/2024.
//

import Foundation

final class StandardTemporaryStore: TemporaryStore {
    private lazy var dictionary = [DatastoreKey: Any]()
    
    func value(forKey key: DatastoreKey) -> Any? {
        dictionary[key]
    }
    
    func set(_ value: Any, forKey key: DatastoreKey) {
        dictionary[key] = value
    }
}
