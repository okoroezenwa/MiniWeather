//
//  MainSavedLocationsProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation
import OSLog

struct MainSavedLocationsProvider: SavedLocationsProvider {
    private let datastore: Datastore
    private let logger: Logger
    private let intPreferenceProvider: PreferencesProvider
    
    init(datastore: Datastore, logger: Logger, intPreferenceProvider: PreferencesProvider) {
        self.datastore = datastore
        self.logger = logger
        self.intPreferenceProvider = intPreferenceProvider
    }
    
    func getSavedLocations() async throws -> [Location] {
        do {
            let locations: [Location] = try datastore.fetch(forKey: .savedItems)
            logger.trace("Fetched saved locations")
            return locations.sorted { $0.position < $1.position }
        } catch DatastoreError.notFound {
            logger.error("Saved locations may be unavailable or not used yet. Returning nil...")
            return []
        } catch {
            logger.error("Could not retrieve saved locations: \(error)")
            throw error
        }
    }
    
    func add(_ location: Location) async throws {
        do {
            let locations: [Location] = try datastore.fetch(forKey: .savedItems)
            let sortedLocations = add(location, to: locations)
            try datastore.store(sortedLocations, withKey: .savedItems)
        } catch DatastoreError.notFound {
            logger.error("Saved locations may be unavailable or not used yet.")
            let newLocations = add(location, to: [])
            try datastore.store(newLocations, withKey: .savedItems)
        } catch {
            throw error
        }
    }
    
    func delete(_ location: Location) async throws {
        do {
            var locations: [Location] = try datastore.fetch(forKey: .savedItems)
            guard let index = locations.firstIndex(where: { $0.fullName == location.fullName }) else {
                throw LocationError.notFound
            }
            locations.remove(at: index)
            locations = adjustPositions(of: locations)
            try datastore.store(locations, withKey: .savedItems)
        } catch {
            throw error
        }
    }
    
    func move(from offsets: IndexSet, to offset: Int) async throws {
        do {
            var locations: [Location] = try datastore.fetch(forKey: .savedItems)
            locations.move(fromOffsets: offsets, toOffset: offset)
            locations = adjustPositions(of: locations)
            try datastore.store(locations, withKey: .savedItems)
        } catch {
            throw error
        }
    }
    
    func changeNickname(ofLocationAt index: Int, to nickname: String) async throws {
        do {
            var locations: [Location] = try datastore.fetch(forKey: .savedItems)
            locations[index].nickname = nickname
            try datastore.store(locations, withKey: .savedItems)
        } catch {
            throw error
        }
    }
    
    func setLocations(to locations: [Location]) async throws {
        do {
            try datastore.store(locations, withKey: .savedItems)
        } catch {
            throw error
        }
    }
    
    private func add(_ location: Location, to locations: [Location]) -> [Location] {
        if locations.isEmpty {
            return [location]
        }
        
        var sortedLocations = locations.sorted { $0.position < $1.position }
        let maxLocations = intPreferenceProvider.integer(forKey: Settings.maxLocations)
        
        if sortedLocations.count == maxLocations {
            sortedLocations.removeLast()
        }
        
        sortedLocations.insert(location, at: 0)
        sortedLocations = adjustPositions(of: sortedLocations)
        return sortedLocations
    }
    
    private func adjustPositions(of locations: [Location]) -> [Location] {
        zip(0..<locations.count, locations)
            .map { $1.atPosition($0) }
    }
}
