//
//  CurrentLocationProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation

///  An object that can resolve and return the user's current location.
protocol CurrentLocationProvider {
    /**
     Gets the user's current location from disk.
     
     - Returns: The user's current location.
     - Throws: LocationError.accessNotDetermined if the user has not yet made a decision on location access, DatastoreError.notFound if the location object is not found on disk, or a DecodeError if the decode operation fails.
     */
    func getCurrentLocation() throws -> Location
    
    /**
     Stores the user's current location on disk.
     
     - Parameter location: The user's current location.
     - Throws: A DecodeError if the encode operation fails.
     */
    func saveCurrentLocation(_ location: Location) throws
}
