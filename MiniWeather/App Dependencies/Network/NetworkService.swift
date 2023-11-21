//
//  NetworkService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

/// An object that processes each request.
protocol NetworkService {
    /**
     Resolves the API request and returns a Data object if successful.
     
     - Returns: A data representation of the object returned by the API call.
     - Parameter request: The request used to make the API call.
     - Throws: An Error object detailing the error that occured.
     */
    func getData(from request: Request) async throws -> Data
}
