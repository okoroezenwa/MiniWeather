//
//  TimeZoneIdentifier.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

struct TimeZoneIdentifier: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case name = "timezone"
        case offset
    }
    
    let name: String
    let offset: Int?
    
    static let empty = Self.init(name: "", offset: nil)
    
    init(name: String, offset: Int?) {
        self.name = name
        self.offset = offset
    }
    
    init(timeZone: TimeZone?) {
        self.name = timeZone?.identifier ?? ""
        self.offset = timeZone?.secondsFromGMT()
    }
}
