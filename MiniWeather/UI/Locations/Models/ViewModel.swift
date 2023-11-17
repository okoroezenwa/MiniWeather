//
//  ViewModel.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 08/11/2023.
//

import Foundation
import CoreLocation

extension LocationsView {
    @Observable class ViewModel {
        private let userLocationAuthorisationRepositoryFactory: () -> UserLocationAuthorisationRepository
        private let userLocationRepositoryFactory: () -> UserLocationRepository
        private let locationsRepositoryFactory: () -> LocationsRepository
        private var status: CLAuthorizationStatus
        private var userLocation: CLLocationCoordinate2D
        private var currentLocation: Location?
        
        static let shared = ViewModel(
            userLocationAuthorisationRepositoryFactory: DependencyFactory.shared.makeUserLocationAuthorisationRepository,
            userLocationRepositoryFactory: DependencyFactory.shared.makeUserLocationRepository,
            locationsRepositoryFactory: DependencyFactory.shared.makeLocationsRepository
        )
        
        init(
            userLocationAuthorisationRepositoryFactory: @escaping () -> UserLocationAuthorisationRepository,
            userLocationRepositoryFactory: @escaping () -> UserLocationRepository,
            locationsRepositoryFactory: @escaping () -> LocationsRepository
        ) {
            self.userLocationAuthorisationRepositoryFactory = userLocationAuthorisationRepositoryFactory
            self.userLocationRepositoryFactory = userLocationRepositoryFactory
            self.locationsRepositoryFactory = locationsRepositoryFactory
            
            status = userLocationAuthorisationRepositoryFactory().getAuthorisationStatus()
            userLocation = .init(latitude: .zero, longitude: .zero)
            
            if status != .notDetermined {
                refreshCurrentLocation(requestingAuthorisation: false)
            }
        }
        
        func getStatus() -> CLAuthorizationStatus {
            status
        }
        
        func getCurrentLocation() -> Location? {
            currentLocation
        }
        
        func refreshStatus() {
            status = userLocationAuthorisationRepositoryFactory().getAuthorisationStatus()
        }
        
        func refreshCurrentLocation(requestingAuthorisation requestAuthorisation: Bool) {
            let userLocationAuthorisationRepository = userLocationAuthorisationRepositoryFactory()
            let userLocationRepository = userLocationRepositoryFactory()
            let locationsRepository = locationsRepositoryFactory()
            
            Task {
                do {
                    let status = if requestAuthorisation {
                        await userLocationAuthorisationRepository.requestLocationAuthorisation()
                    } else {
                        userLocationAuthorisationRepository.getAuthorisationStatus()
                    }
                    
                    if status.isAuthorised() {
                        let coordinates = try await userLocationRepository.getUserLocation()
                        let locations = try await locationsRepository.getLocations(at: coordinates)
                        
                        await MainActor.run {
                            self.status = status
                            self.currentLocation = locations.first
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
