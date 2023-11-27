//
//  OpenWeatherMapReverseGeocodingRequest.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation

/// The API request to get a reverse-geocoded result from OpenWeatherMap.
struct OpenWeatherMapReverseGeocodingRequest: Request {
    var host = "api.openweathermap.org"
    var path = "/geo/1.0/reverse"
    var queryItems: [String: String]
}
