//
//  MainSavedLocationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation

struct MainSavedLocationsRepository: SavedLocationsRepository {
    private let provider: SavedLocationsProvider
    
    init(provider: SavedLocationsProvider) {
        self.provider = provider
    }
    
    func getSavedLocations() async throws -> [Location] {
        try await provider.getSavedLocations()
    }
    
    func add(_ location: Location) async throws {
        try await provider.add(location)
    }
    
    func delete(_ location: Location) async throws {
        try await provider.delete(location)
    }
    
    func move(from offsets: IndexSet, to offset: Int) async throws {
        try await provider.move(from: offsets, to: offset)
    }
    
    func changeNickname(ofLocationAt index: Int, to nickname: String) async throws {
        try await provider.changeNickname(ofLocationAt: index, to: nickname)
    }
}
