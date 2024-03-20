//
//  APINinjasTimeZoneServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import XCTest
@testable import MiniWeather

final class APINinjasTimeZoneServiceTests: XCTestCase {
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

    func test_getTimeZone_SuccessfullyReturnsIdentifier() async throws {
        // Given
        let location = UniversalConstants.location
        let mockRequest = MockRequest(sessionReturnType: .other("APINTimeZoneSuccess"))
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: try JSONEncoder().encode(TimeZoneIdentifier(timeZone: .gmt)), response: .success(url), error: nil)
        
        // When
        let sut = APINinjasTimeZoneService(parser: parser, networkService: networkService, apiKeysProvider: provider, timeZoneRequest: mockRequest)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getTimeZone(for: location))
    }
    
    func test_getTimeZone_ThrowsError() async throws {
        // Given
        let location = UniversalConstants.location
        let mockRequest = MockRequest(sessionReturnType: .other("APINTimeZoneFail"))
        let url = try mockRequest.createURLRequest().url!
        MockURLProtocol.stub(url: url, data: try JSONEncoder().encode(TimeZoneIdentifier(timeZone: .gmt)), response: .fail(url), error: NetworkError.invalidResponse)
        
        // When
        let sut = APINinjasTimeZoneService(parser: parser, networkService: networkService, apiKeysProvider: provider, timeZoneRequest: mockRequest)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getTimeZone(for: location))
    }
}
