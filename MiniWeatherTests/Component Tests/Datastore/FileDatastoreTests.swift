//
//  FileDatastoreTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 04/04/2024.
//

import XCTest
@testable import MiniWeather
import OSLog

final class FileDatastoreTests: XCTestCase {
    private var encoder: DataEncoder!
    private var decoder: DataDecoder!
    private var logger: Logger!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        logger = Logger()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        decoder = nil
        encoder = nil
        logger = nil
    }

    func test_fetch_ReturnsExpectedObject() throws {
        // Given
        let key = DatastoreKey.currentLocation
        let location = MockLocation()
        let data = try! encoder.encode(location)
        let cache = MockCache(store: [key.rawValue: data])
        
        // When
        let sut = FileDatastore(cache: cache, encoder: encoder, decoder: decoder, logger: logger)
        
        // Then
        XCTAssertEqual(try sut.fetch(forKey: key), location, "Items are not equal")
    }
    
    func test_fetch_ThrowsDatastoreError() throws {
        // Given
        let key = DatastoreKey.currentLocation
        let cache = MockCache(store: [:])
        var decodeError: Error?
        
        // When
        let sut = FileDatastore(cache: cache, encoder: encoder, decoder: decoder, logger: logger)
        do {
            let _: MockLocation = try sut.fetch(forKey: key)
        } catch {
            decodeError = error
        }
        
        // Then
        XCTAssertNotNil(decodeError, "Error is nil and therefore none was thrown")
        XCTAssert(decodeError is DatastoreError, "A different error was thrown")
    }
    
    func test_fetch_ThrowsDecodingError() throws {
        // Given
        let key = DatastoreKey.currentLocation
        let location = UniversalConstants.location
        let data = try! encoder.encode(location)
        let cache = MockCache(store: [key.rawValue: data])
        var decodeError: Error?
        
        // When
        let sut = FileDatastore(cache: cache, encoder: encoder, decoder: decoder, logger: logger)
        do {
            let _: MockLocation = try sut.fetch(forKey: key)
        } catch {
            decodeError = error
        }
        
        // Then
        XCTAssertNotNil(decodeError, "Error is nil and therefore none was thrown")
        XCTAssert(decodeError is DecodingError, "A different error was thrown")
    }
    
    func test_store_CompletesSuccessfully() throws {
        // Given
        let key = DatastoreKey.currentLocation
        let location = MockLocation()
        let cache = MockCache(store: [:])
        
        // When
        let sut = FileDatastore(cache: cache, encoder: encoder, decoder: decoder, logger: logger)
        
        // Then
        XCTAssertNoThrow(try sut.store(location, withKey: key), "An error was thrown")
    }
}
