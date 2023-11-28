//
//  MainCurrentLocationProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation
import OSLog

struct MainCurrentLocationProvider: CurrentLocationProvider {
    private let store: Datastore
    private let userLocationAuthorisationProvider: UserLocationAuthorisationProvider
    private let logger: Logger
    
    init(store: Datastore, userLocationAuthorisationProvider: UserLocationAuthorisationProvider, logger: Logger) {
        self.store = store
        self.userLocationAuthorisationProvider = userLocationAuthorisationProvider
        self.logger = logger
    }
    
    func getCurrentLocation() throws -> Location {
        if userLocationAuthorisationProvider.getAuthorisationStatus() == .notDetermined {
            logger.error("Could not get current location as user has not given location access yet")
            throw LocationError.accessNotDetermined
        }
        
        do {
            let location: Location = try store.fetch(forKey: .currentLocation)
            logger.trace("Obtained current location")
            return location
        } catch {
            logger.error("Could not get current location: \(error)")
            throw error
        }
    }
    
    func saveCurrentLocation(_ location: Location) throws {
        do {
            try store.store(location, withKey: .currentLocation)
            logger.trace("Saved \"\(location.city)\" as current location")
        } catch {
            logger.error("Could not save \"\(location.city)\" as current location: \(error)")
            throw error
        }
    }
}
