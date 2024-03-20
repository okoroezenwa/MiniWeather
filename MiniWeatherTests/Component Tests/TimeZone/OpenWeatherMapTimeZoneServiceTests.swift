//
//  OpenWeatherMapTimeZoneServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 20/03/2024.
//

import XCTest
@testable import MiniWeather
import CoreLocation

final class OpenWeatherMapTimeZoneServiceTests: XCTestCase {
    var geocoder: TimeZoneLocationGeocoder!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        geocoder = MockTimeZoneLocationGeocoder()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        geocoder = nil
    }

    func test_getTimeZone_ServiceIsNotOPW_SuccessfullyReturnsTimeZoneIdentifier() async throws {
        // Given
        let location = UniversalConstants.location
        let datastore = MockDatastore(dict: [:])
        
        // When
        let sut = OpenWeatherMapTimeZoneService<MockTimeZoneLocation>(cache: datastore, geocoder: geocoder, weatherService: .apiNinjas)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getTimeZone(for: location))
    }
    
    func test_getTimeZone_ServiceIsOPW_SuccessfullyReturnsTimeZoneIdentifier() async throws {
        // Given
        let location = UniversalConstants.location
        let datastore = MockDatastore(dict: [.timeZone(name:  location.fullName): location.timeZoneIdentifier!])
        
        // When
        let sut = OpenWeatherMapTimeZoneService<MockTimeZoneLocation>(cache: datastore, geocoder: geocoder, weatherService: .openWeatherMap)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getTimeZone(for: location))
    }
    
    func test_getTimeZone_ServiceIsNotOPW_WithTypeMismatch_ThrowsError() async throws {
        // Given
        let location = UniversalConstants.location
        let datastore = MockDatastore(dict: [:])
        
        // When
        let sut = OpenWeatherMapTimeZoneService<CLPlacemark>(cache: datastore, geocoder: geocoder, weatherService: .apiNinjas)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getTimeZone(for: location))
    }
    
    func test_getTimeZone_ServiceIsOPW_ThrowsError() async throws {
        // Given
        let location = UniversalConstants.location
        let datastore = MockDatastore(dict: [:])
        
        // When
        let sut = OpenWeatherMapTimeZoneService<CLPlacemark>(cache: datastore, geocoder: geocoder, weatherService: .openWeatherMap)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getTimeZone(for: location))
    }
}
