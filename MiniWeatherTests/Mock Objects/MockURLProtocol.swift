//
//  MockURLProtocol.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 09/03/2024.
//

import Foundation

class MockURLProtocol: URLProtocol {
    // this dictionary maps URLs to test data
    private static var stubs = [URL: Stub]()
    
    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        
        return Self.stubs[url] != nil
    }
    
    // ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url, let stub = Self.stubs[url] else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    // this method is required but doesn't need to do anything
    override func stopLoading() { }
    
    static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        stubs[url] = Stub(data: data, response: response, error: error)
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        stubs = [:]
    }
}

extension MockURLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
}
