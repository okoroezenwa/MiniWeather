//
//  StandardTemporaryStoreTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 03/04/2024.
//

import XCTest
@testable import MiniWeather

final class StandardTemporaryStoreTests: XCTestCase {

    func test_valueForKey_ReturnsExpectedValue() {
        // Given
        let item = UniversalConstants.location
        let key = DatastoreKey.currentLocation
        
        // When
        let sut = StandardTemporaryStore()
        
        // Then
        sut.set(item, forKey: key)
        XCTAssertEqual(sut.value(forKey: key) as? Location, item, "Items are not equal")
    }
    
    func test_setValueForKey_SavesValueCorrectly() {
        // Given
        let item = [UniversalConstants.location]
        let key = DatastoreKey.savedLocations
        
        // When
        let sut = StandardTemporaryStore()
        
        // Then
        sut.set(item, forKey: key)
        XCTAssertEqual(sut.value(forKey: key) as? [Location], item, "Items are not equal")
    }
}
