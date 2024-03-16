//
//  StandardNetworkServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 14/03/2024.
//

import XCTest
@testable import MiniWeather

final class StandardNetworkServiceTests: XCTestCase {
    private var mockSession: URLSession!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        URLProtocol.registerClass(MockURLProtocol.self)
        
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        mockSession = URLSession(configuration: mockConfiguration)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocol.unregisterClass(MockURLProtocol.self)
        mockSession = nil
    }
    
    func test_StandardNetworkService_getData_ShouldReturnData() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .success)
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: "success".data(using: .utf8), response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        
        // When
        let sut = StandardNetworkService(urlSession: mockSession)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getData(from: mockRequest), "An error was thrown")
    }
    
    func test_StandardNetworkService_getData_shouldReturnBadURLError() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .error)
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: nil, response: nil, error: NetworkError.badURL)
        
        // When
        let sut = StandardNetworkService(urlSession: mockSession)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getData(from: mockRequest)/*, NetworkError.badURL*/)
    }
    
    func test_StandardNetworkService_getData_shouldReturnOperationFailedError() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .failure)
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: nil, response: nil, error: NetworkError.operationFailed)
        
        // When
        let sut = StandardNetworkService(urlSession: mockSession)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getData(from: mockRequest)/*, NetworkError.operationFailed*/)
    }
    
    func test_StandardNetworkService_getData_shouldThrowInvalidOperationError() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .invalidResponse)
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: "success".data(using: .utf8), response: HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil), error: nil)
        
        // When
        let sut = StandardNetworkService(urlSession: mockSession)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getData(from: mockRequest)/*, NetworkError.operationFailed*/)
    }
}
