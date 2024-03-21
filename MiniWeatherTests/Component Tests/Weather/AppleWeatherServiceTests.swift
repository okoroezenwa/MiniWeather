//
//  AppleWeatherServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import XCTest
@testable import MiniWeather
import CoreLocation
import WeatherKit

final class AppleWeatherServiceTests: XCTestCase {
    var provider: WeatherProvider!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        provider = MockWeatherProvider()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        provider = nil
    }

    func test_getWeather_SuccessfullyReturnsWeatherObject() async throws {
        // Given
        let location = UniversalConstants.location
        
        // When
        let sut = AppleWeatherService<MockWeather>(provider: provider)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getWeather(for: location))
    }
    
    func test_getWeather_TypeMismatch_ThrowsError() async throws {
        // Given
        let location = UniversalConstants.location
        
        // When
        let sut = AppleWeatherService<WeatherKit.Weather>(provider: provider)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getWeather(for: location))
    }
}
