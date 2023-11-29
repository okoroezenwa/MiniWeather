//
//  KeyValueStore.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 29/11/2023.
//

import Foundation

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
