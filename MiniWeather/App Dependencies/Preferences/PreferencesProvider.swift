//
//  PreferencesProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/12/2023.
//

import Foundation

protocol StringPreferenceProvider {
    func string(forKey service: String) -> String?
}

extension UserDefaults: StringPreferenceProvider { }
