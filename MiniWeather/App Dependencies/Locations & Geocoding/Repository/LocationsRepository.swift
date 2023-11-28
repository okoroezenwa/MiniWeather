//
//  LocationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/10/2023.
//

import Foundation
import CoreLocation

/// An object that can return a set of locations.
protocol LocationsRepository {
    /**
     Gets a set of locations based on a search term.
     
     - Returns: An array containing any locations that match the search term, otherwise an empty array.
     - Parameter searchText: The search term used to obtains the locations.
     - Throws: CLError.Code.geocodeCanceled if the request was stopped, CLError.Code.geocodeFoundNoResult if no result was found, CLError.Code.geocodeFoundPartialResult if a partial result was found, or CLError.Code.network if too many request have been made.
     */
    func getLocations(named searchText: String) async throws -> [Location]
    
    /**
     Gets a set of locations based on a set of coordinates.
     
     - Returns: An array containing any locations that match the coordinates, otherwise an empty array.
     - Parameter coordinates: The coordinatess used to obtains the locations.
     - Throws: CLError.Code.geocodeCanceled if the request was stopped, CLError.Code.geocodeFoundNoResult if no result was found, CLError.Code.geocodeFoundPartialResult if a partial result was found, or CLError.Code.network if too many request have been made.
     */
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location]
}
