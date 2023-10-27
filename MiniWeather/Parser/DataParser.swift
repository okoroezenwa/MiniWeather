//
//  DataParser.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/10/2023.
//

import Foundation

protocol DataParser {
    func decode<Response: Decodable>(_ data: Data) throws -> Response
}
