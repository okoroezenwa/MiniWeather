//
//  PreferencesRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 26/04/2024.
//

import Foundation

protocol PreferencesRepository: Sendable {
    func string(forKey key: String) -> String?
    func integer(forKey key: String) -> Int
}
