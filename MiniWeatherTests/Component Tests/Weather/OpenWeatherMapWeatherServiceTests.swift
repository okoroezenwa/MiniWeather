//
//  OpenWeatherMapWeatherServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import XCTest
@testable import MiniWeather

final class OpenWeatherMapWeatherServiceTests: XCTestCase {
    var session: URLSession!
    var parser: DataParser!
    var networkService: NetworkService!
    var provider: StringPreferenceProvider!
    var store: Datastore!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        URLProtocol.registerClass(MockURLProtocol.self)
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        
        session = URLSession(configuration: mockConfiguration)
        parser = MockDataParser(decoder: .init())
        networkService = MockNetworkService(urlSession: session)
        provider = MockAPIKeysProvider()
        store = MockDatastore(dict: [:])
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocol.unregisterClass(MockURLProtocol.self)
        session = nil
        parser = nil
        networkService = nil
        provider = nil
        store = nil
    }
    
    func test_getWeather_SuccessfullyReturnsWeatherObject() async throws {
        // Given
        let location = UniversalConstants.location
        let weather = MockWeather()
        let request = MockRequest(sessionReturnType: .other("OWMWeatherSuccess"))
        let url = try request.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: try JSONEncoder().encode(weather), response: .success(url), error: nil)
        
        // When
        let sut = OpenWeatherMapWeatherService<MockWeather>(parser: parser, timeZoneDatastore: store, networkService: networkService, apiKeysProvider: provider, weatherRequest: request)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getWeather(for: location))
    }
    
    func test_getWeather_ThrowsError() async throws {
        // Given
        let location = UniversalConstants.location
        let weather = MockWeather()
        let request = MockRequest(sessionReturnType: .other("OWMWeatherFail"))
        let url = try request.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: try JSONEncoder().encode(weather), response: .fail(url), error: NetworkError.invalidResponse)
        
        // When
        let sut = OpenWeatherMapWeatherService<MockWeather>(parser: parser, timeZoneDatastore: store, networkService: networkService, apiKeysProvider: provider, weatherRequest: request)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getWeather(for: location))
    }
}
