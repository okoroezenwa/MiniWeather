//
//  TimeZoneIdentifier.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

struct TimeZoneIdentifier: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "timezone"
        case offset
    }
    
    let name: String
    let offset: Int?
}
