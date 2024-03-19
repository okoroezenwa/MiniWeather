//
//  MockAPIKeysProvider.swift
//  MiniWeatherTests
//
//  Created by Ezenwa Okoro on 17/03/2024.
//

import Foundation
@testable import MiniWeather

final class MockAPIKeysProvider: StringPreferenceProvider {
    func string(forKey service: String) -> String? {
        return "string"
    }
}
