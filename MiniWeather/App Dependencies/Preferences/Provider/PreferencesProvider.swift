//
//  PreferencesProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/12/2023.
//

import Foundation

protocol PreferencesProvider: Sendable {
    func string(forKey service: String) -> String?
    func integer(forKey service: String) -> Int
}

// According to docs UserDefaults is thread-safe so I think this makes sense?
extension UserDefaults: PreferencesProvider, @unchecked Sendable { }
