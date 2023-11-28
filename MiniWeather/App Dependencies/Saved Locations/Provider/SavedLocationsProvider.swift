//
//  SavedLocationsProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation

/// An object that resolves and returns the user's saved locations.
protocol SavedLocationsProvider {
    /**
     Gets the user's saved locations from disk.
     
     - Returns: The user's saved locations.
     - Throws: An error.
     */
    func getSavedLocations() async throws -> [Location]
    
    /**
     Adds a location to the list of saved locations.
     
     - Parameter location: The location to be added.
     - Throws: An error.
     */
    func add(_ location: Location) async throws
    
    /**
     Deletes a location from the list of saved locations.
     
     - Parameter location: The location to be deleted.
     - Throws: An error.
     */
    func delete(_ location: Location) async throws
}
