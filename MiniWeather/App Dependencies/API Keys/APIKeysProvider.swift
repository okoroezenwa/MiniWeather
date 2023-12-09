//
//  APIKeysProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/12/2023.
//

import Foundation

protocol APIKeysProvider {
    func getAPIKey(for service: String) -> String
}
