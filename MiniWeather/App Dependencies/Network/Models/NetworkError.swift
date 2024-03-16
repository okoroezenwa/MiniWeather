//
//  NetworkError.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

enum NetworkError: LocalizedError {
    case badURL
    case invalidResponse
    case invalidURL
    case failedDecode
    case operationFailed
}
