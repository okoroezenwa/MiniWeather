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
    }
    
    let name: String
}
