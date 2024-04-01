//
//  MainSavedLocationsProviderTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 22/03/2024.
//

import XCTest
@testable import MiniWeather
import OSLog

final class MainSavedLocationsProviderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getSavedLocations_SuccessfullyReturnsLocations() async throws {
        // Given
        let locations = [UniversalConstants.location]
        let datastore = MockDatastore(dict: [.savedLocations: locations])
        
        // When
        let sut = MainSavedLocationsProvider(datastore: datastore, logger: Logger())
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.getSavedLocations())
        
        let savedLocations = try await sut.getSavedLocations()
        XCTAssertEqual(locations, savedLocations)
    }
    
    func test_getSavedLocations_ThrowsError() async throws {
        // Given
        let datastore = MockDatastore(dict: nil)
        
        // When
        let sut = MainSavedLocationsProvider(datastore: datastore, logger: Logger())
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.getSavedLocations())
    }
    
    func test_addLocation_ThrowsNoError() async throws {
        // Given
        let location = UniversalConstants.location
        let datastore = MockDatastore(dict: [.currentLocation: [location]])
        
        // When
        let sut = MainSavedLocationsProvider(datastore: datastore, logger: Logger())
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.add(location))
    }
    
    func test_addLocation_ThrowsError() async throws {
        // Given
        let location = UniversalConstants.location
        let datastore = MockDatastore(dict: nil)
        
        // When
        let sut = MainSavedLocationsProvider(datastore: datastore, logger: Logger())
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.add(location))
    }
    
    func test_deleteLocations_ThrowsNoError() async throws {
        // Given
        let location = UniversalConstants.location
        let locations = [UniversalConstants.location]
        let datastore = MockDatastore(dict: [.savedLocations: locations])
        
        // When
        let sut = MainSavedLocationsProvider(datastore: datastore, logger: Logger())
        
        // Then
        await XCTAssertNoThrowAsync(try await sut.delete(location))
    }
    
    func test_deleteLocations_ThrowsError() async throws {
        // Given
        let location = UniversalConstants.location
        let datastore = MockDatastore(dict: [:])
        
        // When
        let sut = MainSavedLocationsProvider(datastore: datastore, logger: Logger())
        
        // Then
        await XCTAssertThrowsAsyncError(try await sut.delete(location))
    }
}
