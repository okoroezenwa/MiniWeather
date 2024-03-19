//
//  MockDataParser.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
@testable import MiniWeather

final class MockDataParser: DataParser {
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    func decode<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.failedDecode
        }
    }
}
