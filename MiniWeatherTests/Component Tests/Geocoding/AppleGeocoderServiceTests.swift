//
//  AppleGeocoderServiceTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 19/03/2024.
//

import XCTest
import CoreLocation
@testable import MiniWeather

final class AppleGeocoderServiceTests: XCTestCase {
    var geocoder: TimeZoneLocationGeocoder!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        geocoder = MockTimeZoneLocationGeocoder()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        geocoder = nil
    }

    func test_getLocationsNamed_LocationsReturnedSuccessfully() async throws {
        // Given
        let name = "Test"
        
        // When
        let sut = AppleGeocoderService<MockTimeZoneLocation>(geocoder: geocoder)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getLocations(named: name), "An error was thrown")
    }
    
    func test_getLocationsNamed_ErrorReturned() async throws {
        // Given
        let name = "Test"
        
        // When
        let sut = AppleGeocoderService<CLPlacemark>(geocoder: geocoder)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getLocations(named: name))
    }
    
    func test_getLocationAt_LocationsReturnedSuccessfully() async throws {
        // Given
        let name = "Test"
        let coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // When
        let sut = AppleGeocoderService<MockTimeZoneLocation>(geocoder: geocoder)
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getLocations(at: coordinates), "An error was thrown")
    }
    
    func test_getLocationAt_ErrorReturned() async throws {
        // Given
        let name = "Test"
        let coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // When
        let sut = AppleGeocoderService<CLPlacemark>(geocoder: geocoder)
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getLocations(at: coordinates))
    }
}
