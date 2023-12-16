//
//  TimeZone+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 15/12/2023.
//

import Foundation

extension TimeZone {
    static func from(identifier: TimeZoneIdentifier) -> TimeZone? {
        if let offset = identifier.offset {
            return TimeZone(secondsFromGMT: offset)
        }
        return TimeZone(identifier: identifier.name)
    }
}
