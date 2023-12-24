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
        timeZone: .init(timeZone: TimeZone.autoupdatingCurrent),
        latitide: 0,
        longitude: 0
    )
    
    static let weather = APINinjasWeather(
        temperature: .init(value: 20, unit: .celsius),
        apparentTemperature: .init(value: 19, unit: .celsius),
        minimumTemperature: .init(value: 16, unit: .celsius),
        maximumTemperature: .init(value: 23, unit: .celsius),
        humidity: 87,
        windSpeed: .init(value: 10, unit: .kilometersPerHour),
        windDirection: .init(value: 210, unit: .degrees),
        sunrise: .init(timeIntervalSince1970: 1615616341),
        sunset: .init(timeIntervalSince1970: 1615658463),
        cloudPercentage: 75
    )
}
