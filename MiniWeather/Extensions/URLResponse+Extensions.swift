//
//  URLResponse+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import Foundation

extension URLResponse {
    static func success(_ url: URL) -> URLResponse? {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
    }
    
    static func fail(_ url: URL) -> URLResponse? {
        HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
    }
}
