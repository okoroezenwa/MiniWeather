//
//  NetworkService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 23/10/2023.
//

import Foundation

class StandardNetworkService: NetworkService {
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
