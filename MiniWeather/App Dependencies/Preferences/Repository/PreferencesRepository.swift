//
//  PreferencesRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 26/04/2024.
//

import Foundation

/// An object that retrieves a user's preferences.
protocol PreferencesRepository: Sendable {
    /**
     Retrieves the value of a preference stored as a string.
     
     - Returns: The string value of the preference stored.
     - Parameter key: The key used to obtain the string preference.
     */
    func string(forKey key: String) -> String?
    
    /**
     Retrieves the value of a preference stored as an integer.
     
     - Returns: The integer value of the preference stored.
     - Parameter key: The key used to obtain the integer preference.
     */
    func integer(forKey key: String) -> Int
}
