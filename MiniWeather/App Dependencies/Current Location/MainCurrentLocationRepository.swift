//
//  MainCurrentLocationRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 28/11/2023.
//

import Foundation
import OSLog

struct MainCurrentLocationRepository: CurrentLocationRepository {
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
            throw LocationError.accessNotDetermined
        }
        
        do {
            let location = store.fetch(forKey: .currentLocation)
        } catch {
            
        }
    }
}
