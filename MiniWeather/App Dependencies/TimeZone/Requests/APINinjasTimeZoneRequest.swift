//
//  APINinjasTimeZoneRequest.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

/// The API request to get a time zone from API-Ninjas.
struct APINinjasTimeZoneRequest: Request {
    var host = "api.api-ninjas.com"
    var path = "/v1/timezone"
    var queryItems: [String: String]
    var headers: [String: String]
}
