//
//  PreferencesProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/12/2023.
//

import Foundation
#warning("Organise later")
protocol PreferencesProvider {
    func string(forKey service: String) -> String?
    func integer(forKey service: String) -> Int
}

extension UserDefaults: PreferencesProvider { }

protocol PreferencesRepository {
    func string(forKey key: String) -> String?
    func integer(forKey key: String) -> Int
}

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
