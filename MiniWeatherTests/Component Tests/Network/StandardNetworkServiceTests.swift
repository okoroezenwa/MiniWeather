//
//  StandardNetworkServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 14/03/2024.
//

import XCTest
@testable import MiniWeather

final class StandardNetworkServiceTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }
    
    func test_onGetDataCall_DataIsReturnedAndNoErrorThrown() async throws {
        let mockRequest = MockRequest(sessionReturnType: .success)
        let url = try mockRequest.createURLRequest().url!
        
        MockURLProtocol.stub(url: url, data: "success".data(using: .utf8), response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        let mockSession = URLSession(configuration: mockConfiguration)
        
        let sut = StandardNetworkService(urlSession: mockSession)
        await XCTAssertNoThrowAsync(try await sut.getData(from: mockRequest), "An error was thrown")
    }
    
    func test_onGetDataCall_ErrorIsReturned() async throws {
        let mockRequest = MockRequest(sessionReturnType: .error)
        let url = try mockRequest.createURLRequest().url!
        
        MockURLProtocol.stub(url: url, data: nil, response: nil, error: NetworkError.badURL)
        
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        let mockSession = URLSession(configuration: mockConfiguration)
        
        let sut = StandardNetworkService(urlSession: mockSession)
        await XCTAssertThrowsAsyncError(try await sut.getData(from: mockRequest)/*, NetworkError.badURL*/)
    }
    
    func test_onGetDataCall_OperationFails() async throws {
        let mockRequest = MockRequest(sessionReturnType: .failure)
        let url = try mockRequest.createURLRequest().url!
        
        MockURLProtocol.stub(url: url, data: nil, response: nil, error: NetworkError.operationFailed)
        
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        let mockSession = URLSession(configuration: mockConfiguration)
        
        let sut = StandardNetworkService(urlSession: mockSession)
        await XCTAssertThrowsAsyncError(try await sut.getData(from: mockRequest)/*, NetworkError.operationFailed*/)
    }
    
    func test_onGetDataCall_InvalidOperationErrorThrown() async throws {
        let mockRequest = MockRequest(sessionReturnType: .invalidResponse)
        
        guard let url = try? mockRequest.createURLRequest().url else {
            XCTFail("Expected non-nil URL")
            return
        }
        
        MockURLProtocol.stub(url: url, data: "success".data(using: .utf8), response: HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil), error: nil)
        
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        let mockSession = URLSession(configuration: mockConfiguration)
        
        let sut = StandardNetworkService(urlSession: mockSession)
        await XCTAssertThrowsAsyncError(try await sut.getData(from: mockRequest)/*, NetworkError.operationFailed*/)
    }
}
