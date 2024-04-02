//
//  TemporaryStore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 02/04/2024.
//

import Foundation

/// An object that provides a temporary storage for a datastore.
protocol TemporaryStore {
    /**
     Retrieves a stored object from internal storage.
     
     - Returns: The object requested.
     - Parameter key: The key used to obtain the stored object.
     */
    func value(forKey key: DatastoreKey) -> Any?
    
    /**
     Stores the given object in internal storage.
     
     - Parameters:
     - value: The object to store.
     - key: The key used to identify the object.
     */
    func set(_ value: Any, forKey key: DatastoreKey)
}
