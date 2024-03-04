//
//  KeyValueStore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 29/11/2023.
//

import Foundation

/// An object that can retrieve a data representation of an object from its store.
protocol KeyValueStore {
    /**
     Retrieves the data representation of an object for a given key from the store.
     
     - Returns: The data representation of the object.
     - Parameter forKey: The key used to retrieve the data object.
     */
    func data(forKey: String) -> Data?
    
    /**
     Stores the data representation of an object with the specified key.
     
     - Parameters:
        - value: The data representation of the object that will be stored.
        - forKey: The key to identify the object stored.
     */
    func set(_ value: Any?, forKey: String)
    
    /**
     Synchronises the data stored.
     
     - Returns: Whether the stored items were synchronised successfully.
     */
    func synchronize() -> Bool
}

/// An object that can decode a Decodable type from its data representation.
protocol DataDecoder {
    /**
     Decodes an object of a given type to from its data representation.
     
     - Returns: The decoded object.
     - Parameters:
         - type: The type of the object to be decoded to.
         - data: The data representation of the object.
     */
    func decode<Object>(_ type: Object.Type, from data: Data) throws -> Object where Object : Decodable
}

/// An object that can encode an object to its data representation.
protocol DataEncoder {
    /**
     Encodes an object to its data representation.
     
     - Parameter object: The object to be encoded.
     - Returns: The data representation of the object.
     */
    func encode<Object: Encodable>(_ object: Object) throws -> Data
}

extension JSONDecoder: DataDecoder { }

extension JSONEncoder: DataEncoder { }

extension UserDefaults: KeyValueStore { }

extension NSUbiquitousKeyValueStore: KeyValueStore { }
