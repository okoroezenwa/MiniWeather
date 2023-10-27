//
//  NetworkService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation

protocol NetworkService {
    func getData(from request: Request) async throws -> Data
}
