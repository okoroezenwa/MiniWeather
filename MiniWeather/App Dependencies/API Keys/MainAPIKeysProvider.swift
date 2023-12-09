//
//  MainAPIKeysProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/12/2023.
//

import Foundation

struct MainAPIKeysProvider: APIKeysProvider {
    let defaults: UserDefaults
    
    func getAPIKey(for service: String) -> String {
        defaults.string(forKey: service) ?? ""
    }
}
