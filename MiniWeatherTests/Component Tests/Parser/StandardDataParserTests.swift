//
//  StandardDataParserTests.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 15/03/2024.
//

import XCTest
@testable import MiniWeather

final class StandardDataParserTests: XCTestCase {
    private var sut: StandardDataParser!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = StandardDataParser(decoder: JSONDecoder.init())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func test_StandardDataParser_decode_shouldReturnString() throws {
        // Given
        let string = "{\"message\":\"success\"}"
        let data = string.data(using: .utf8)!
        var parserError: Error?
        
        // When
        do {
            let _: ExampleJSON = try sut.decode(data)
        } catch {
            parserError = error
        }
        
        // Then
        XCTAssertNil(parserError, "Error should be nil")
    }
    
    func test_StandardDataParser_decode_shouldThrowError() throws {
        // Given
        let string = "/{\"message\":\"success\"}"
        let data = string.data(using: .utf8)!
        var parserError: Error?
        
        // When
        do {
            let _: ExampleJSON = try sut.decode(data)
            XCTFail("An error should be thrown")
        } catch {
            parserError = error
        }
        
        // Then
        XCTAssertNotNil(parserError, "Error should be non-nil")
    }
}

struct ExampleJSON: Decodable {
    let message: String
}
