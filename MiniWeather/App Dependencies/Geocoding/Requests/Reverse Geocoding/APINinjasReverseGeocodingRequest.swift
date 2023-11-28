//
//  APINinjasReverseGeocodingRequest.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation

/// The API request to get a reverse geocoding result from API-Ninjas.
struct APINinjasReverseGeocodingRequest: Request {
    var host = "api.api-ninjas.com"
    var path = "/v1/reversegeocoding"
    var queryItems: [String: String]
    var headers: [String: String]
}
