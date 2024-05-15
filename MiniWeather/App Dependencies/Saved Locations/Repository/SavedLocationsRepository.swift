//
//  SavedLocationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation

protocol SavedLocationsRepository {
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
    
    /**
     Moves one or more locations from their current positions in the list of saved locations to another.
     
     - Parameters:
     - offsets: The offsets the selected locations will be moved from.
     - offset: The position the locations will be moved to.
     - Throws: An error.
     */
    func move(from offsets: IndexSet, to offset: Int) async throws
    
    /**
     Sets the nickname of the given location to the passed string value.
     
     - Parameters:
        - index: The index of the location to update.
        - nickname: The value to set as the location's nickname.
     - Throws: An error.
     */
    func changeNickname(ofLocationAt index: Int, to nickname: String) async throws
    
    func setLocations(to locations: [Location]) async throws
}
