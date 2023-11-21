//
//  DataParser.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 25/10/2023.
//

import Foundation

/// An object that parses the result of a network call.
protocol DataParser {
    /**
     Decodes a data object.
     
     - Returns: An object conforming to Decodable.
     - Parameter data: The Data object to decode.
     - Throws: NetworkError.failedDecode if unable to decode the object.
     */
    func decode<Response: Decodable>(_ data: Data) throws -> Response
}
