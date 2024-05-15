//
//  PreferencesProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/12/2023.
//

import Foundation

/// An object that provides access to a user's preferences.
protocol PreferencesProvider: Sendable {
    /**
     Provides the value of a preference stored as a string.
     
     - Returns: The string value of the preference stored.
     - Parameter key: The key used to obtain the string preference.
     */
    func string(forKey key: String) -> String?
    
    /**
     Provides the value of a preference stored as an integer.
     
     - Returns: The integer value of the preference stored.
     - Parameter key: The key used to obtain the integer preference.
     */
    func integer(forKey key: String) -> Int
}

// According to docs UserDefaults is thread-safe so I think this makes sense?
extension UserDefaults: PreferencesProvider, @unchecked Sendable { }
