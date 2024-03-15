//
//  MockRequest.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 14/03/2024.
//

@testable import MiniWeather
import Foundation

struct MockRequest: Request {
    private let sessionReturnType: SessionReturnType
    
    init(sessionReturnType: SessionReturnType) {
        self.sessionReturnType = sessionReturnType
    }
    
    var host: String {
        switch sessionReturnType {
            case .success:
                "successURL"
            case .error:
                "errorURL"
            case .failure:
                "failureURL"
            case .invalidResponse:
                "invalidURL"
        }
    }
    
    let path = ""
}

enum SessionReturnType {
    case success, error, failure, invalidResponse
}
