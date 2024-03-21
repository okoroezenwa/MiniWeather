//
//  OpenWeatherMapGeocoderServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 19/03/2024.
//

import XCTest
import CoreLocation
@testable import MiniWeather

final class OpenWeatherMapGeocoderServiceTests: XCTestCase {
    var session: URLSession!
    var parser: DataParser!
    var networkService: NetworkService!
    var provider: StringPreferenceProvider!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        URLProtocol.registerClass(MockURLProtocol.self)
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        
        session = URLSession(configuration: mockConfiguration)
        parser = MockDataParser(decoder: .init())
        networkService = MockNetworkService(urlSession: session)
        provider = MockAPIKeysProvider()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocol.unregisterClass(MockURLProtocol.self)
        session = nil
        parser = nil
        networkService = nil
        provider = nil
    }
    
    func test_getLocationsNamed_LocationsReturnedSuccessfully() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .other("APINNamedSuccess"))
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: try JSONEncoder().encode([MockLocation()]), response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        let name = "Test"
        
        // When
        let sut = OpenWeatherMapGeocoderService<MockLocation>(parser: parser, networkService: networkService, apiKeysProvider: provider, geocodingRequest: mockRequest)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getLocations(named: name), "An error was thrown")
    }
    
    func test_getLocationsNamed_ErrorReturned() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .other("APINNamedFail"))
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: nil, response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), error: NetworkError.operationFailed)
        let name = "Test"
        
        // When
        let sut = OpenWeatherMapGeocoderService<MockLocation>(parser: parser, networkService: networkService, apiKeysProvider: provider, geocodingRequest: mockRequest)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getLocations(named: name))
    }
    
    func test_getLocationAt_LocationsReturnedSuccessfully() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .other("APINAtSuccess"))
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: try JSONEncoder().encode([MockLocation()]), response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        let coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // When
        let sut = OpenWeatherMapGeocoderService<MockLocation>(parser: parser, networkService: networkService, apiKeysProvider: provider, reverseGeocodingRequest: mockRequest)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getLocations(at: coordinates), "An error was thrown")
    }
    
    func test_getLocationAt_ErrorReturned() async throws {
        // Given
        let mockRequest = MockRequest(sessionReturnType: .other("APINAtFail"))
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: nil, response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), error: NetworkError.operationFailed)
        let coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // When
        let sut = OpenWeatherMapGeocoderService<MockLocation>(parser: parser, networkService: networkService, apiKeysProvider: provider, reverseGeocodingRequest: mockRequest)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getLocations(at: coordinates))
    }
}
