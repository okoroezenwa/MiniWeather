//
//  CKRecordFieldKey+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit

extension CKRecord.FieldKey {
    static let id = "id"
    static let timestamp = "timestamp"
    static let city = "city"
    static let state = "state"
    static let country = "country"
    static let position = "position"
    static let nickname = "nickname"
    static let timeZoneIdentifier = "timeZoneIdentifier"
    static let timeZoneOffset = "timeZoneOffset"
    static let longitude = "longitude"
    static let latitude = "latitude"
    static let lastModified = "lastModified"
}

extension CKRecord.FieldKey {
    enum Kind {
        case encrypted(CKRecord.FieldKey)
        case unencrypted(CKRecord.FieldKey)
    }
}
