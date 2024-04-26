//
//  MainPreferencesRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 26/04/2024.
//

import Foundation

final class MainPreferencesRepository: PreferencesRepository {
    private let provider: PreferencesProvider
    
    init(provider: PreferencesProvider) {
        self.provider = provider
    }
    
    func string(forKey key: String) -> String? {
        provider.string(forKey: key)
    }
    
    func integer(forKey key: String) -> Int {
        provider.integer(forKey: key)
    }
}
