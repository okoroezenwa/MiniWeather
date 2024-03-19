//
//  MockPartialLocation.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
@testable import MiniWeather

struct MockPartialLocation: PartialLocationProtocol, Codable {
    var city: String = "Abuja"
    var state: String? = "FCT"
    var countryName: String = "Nigeria"
    
    
}
