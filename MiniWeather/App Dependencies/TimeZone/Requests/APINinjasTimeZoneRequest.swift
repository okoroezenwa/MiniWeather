//
//  APINinjasTimeZoneRequest.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

struct APINinjasTimeZoneRequest: Request {
    var host = "api.api-ninjas.com"
    var path = "/v1/timezone"
    var queryItems: [String: String]
    var headers: [String: String]
}
