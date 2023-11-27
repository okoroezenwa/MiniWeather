//
//  OpenWeatherMapWeatherRequest.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/11/2023.
//

import Foundation

/// The API request to get weather info from OpenWeatherMap.
struct OpenWeatherMapWeatherRequest: Request {
    var host = "api.openweathermap.org"
    var path = "/data/3.0/onecall"
    var queryItems: [String: String]
}
