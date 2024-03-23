//
//  MainCurrentLocationProviderTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 22/03/2024.
//

import XCTest
@testable import MiniWeather
import OSLog

final class MainCurrentLocationProviderTests: XCTestCase {
    var datastore: Datastore!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        datastore = MockDatastore(dict: [:])
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        datastore = nil
    }

    func test_getCurrentLocation_SuccessfullyReturnsLocation() throws {
        // Given
        let location = UniversalConstants.location
        let authProvider = MockUserLocationAuthorisationProvider(status: .authorizedWhenInUse)
        let datastore = MockDatastore(dict: [.currentLocation: location])
        
        // When
        let sut = MainCurrentLocationProvider(store: datastore, userLocationAuthorisationProvider: authProvider, logger: Logger())
        
        // Then
        try sut.saveCurrentLocation(UniversalConstants.location)
        XCTAssertNoThrow(try sut.getCurrentLocation(), "An error was thrown")
    }
    
    func test_getCurrentLocation_LocationAccessNotDetermined_ThrowsError() throws {
        // Given
        let location = UniversalConstants.location
        let authProvider = MockUserLocationAuthorisationProvider(status: .notDetermined)
        let datastore = MockDatastore(dict: [.currentLocation: location])
        
        // When
        let sut = MainCurrentLocationProvider(store: datastore, userLocationAuthorisationProvider: authProvider, logger: Logger())
        
        // Then
        XCTAssertThrowsError(try sut.getCurrentLocation(), "No error was thrown")
    }
    
    func test_getCurrentLocation_NoLocation_ThrowsError() throws {
        // Given
        let authProvider = MockUserLocationAuthorisationProvider(status: .authorizedWhenInUse)
        
        // When
        let sut = MainCurrentLocationProvider(store: datastore, userLocationAuthorisationProvider: authProvider, logger: Logger())
        
        // Then
        XCTAssertThrowsError(try sut.getCurrentLocation(), "No error was thrown")
    }
    
    func test_saveCurrentLocation_SavedSuccessfully() {
        // Given
        let authProvider = MockUserLocationAuthorisationProvider(status: .authorizedWhenInUse)
        let location = UniversalConstants.location
        
        // When
        let sut = MainCurrentLocationProvider(store: datastore, userLocationAuthorisationProvider: authProvider, logger: Logger())
        
        // Then
        XCTAssertNoThrow(try sut.saveCurrentLocation(location), "An error was thrown")
    }
}
