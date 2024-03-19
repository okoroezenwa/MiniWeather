//
//  MockNetworkService.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
@testable import MiniWeather

final class MockNetworkService: NetworkService {
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func getData(from request: Request) async throws -> Data {
        do {
            let (data, response) = try await urlSession.data(for: request.createURLRequest())

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            return data
        } catch {
            throw NetworkError.operationFailed
        }
    }
}
