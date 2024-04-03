//
//  MemoryDatastoreTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 03/04/2024.
//

import XCTest
import OSLog
@testable import MiniWeather

final class MemoryDatastoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_fetch_ReturnsExpectedObject() throws {
        // Given
        let key = DatastoreKey.currentLocation
        let location = MockLocation()
        let temporaryStore = MockTemporaryStore(dictionary: [key: location])
        
        // When
        let sut = MemoryDatastore(store: temporaryStore, logger: Logger())
        
        // Then
        XCTAssertEqual(try sut.fetch(forKey: key), location, "Items are not equal")
    }
    
    func test_fetch_ThrowsError() throws {
        // Given
        let key = DatastoreKey.currentLocation
        let temporaryStore = MockTemporaryStore(dictionary: [:])
        var decodeError: Error?
        
        // When
        let sut = MemoryDatastore(store: temporaryStore, logger: Logger())
        do {
            let _: MockLocation = try sut.fetch(forKey: key)
        } catch {
            decodeError = error
        }
        
        // Then
        XCTAssertNotNil(decodeError, "Error is nil and therefore none was thrown")
    }
    
    func test_store_throwsNoErrorAndStoresSuccessfully() throws {
        // Given
        let key = DatastoreKey.currentLocation
        let location = MockLocation()
        let temporaryStore = MockTemporaryStore(dictionary: [:])
        
        // When
        let sut = MemoryDatastore(store: temporaryStore, logger: Logger())
        
        // Then
        XCTAssertNoThrow(try sut.store(location, withKey: key), "An error was thrown")
        XCTAssertEqual(try sut.fetch(forKey: key), location, "Items are not equal")
    }
}
