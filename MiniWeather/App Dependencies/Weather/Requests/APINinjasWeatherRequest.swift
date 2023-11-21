//
//  APINinjasWeatherRequest.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 31/10/2023.
//

import Foundation

/// The API request to get weather info from API-Ninjas.
struct APINinjasWeatherRequest: Request {
    var host = "api.api-ninjas.com"
    var path = "/v1/weather"
    var queryItems: [String: String]
    var headers: [String: String]
}
