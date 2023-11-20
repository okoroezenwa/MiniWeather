//
//  UniversalConstants.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import Foundation

struct UniversalConstants {
    static let location = Location(
        city: "Abuja",
        state: "FCT",
        country: "Nigeria",
        nickname: "Home",
        timeZone: TimeZone.autoupdatingCurrent.identifier,
        latitide: 0,
        longitude: 0
    )
    
    static let weather = Weather(
        temperature: 20,
        feelsLike: 19,
        minimumTemperature: 16,
        maximumTemperature: 23,
        humidity: 87,
        windSpeed: 10,
        windDegrees: 210,
        sunrise: 1615616341,
        sunset: 1615658463,
        cloudPercentage: 75
    )
}
