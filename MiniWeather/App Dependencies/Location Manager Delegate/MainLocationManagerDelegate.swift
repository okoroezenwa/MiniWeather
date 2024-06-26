//
//  MainLocationManagerDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 20/11/2023.
//

import Foundation
import CoreLocation

final class MainLocationManagerDelegate: NSObject, LocationManagerDelegate {
    private let locationManager: CLLocationManager
    // Checked continuation objects to bridge delegate functions with async functions
    private var userLocationCheckedThrowingContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var locationAuthorisationCheckedContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    // MARK: - UserLocationAuthorisationProvider
    func getAuthorisationStatus() -> CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    func requestLocationAuthorisation() async -> CLAuthorizationStatus {
        if locationManager.authorizationStatus == .notDetermined {
            return await withCheckedContinuation { [weak self] continuation in
                guard let self else {
                    return
                }
                self.locationAuthorisationCheckedContinuation = continuation
                #if os(iOS)
                locationManager.requestWhenInUseAuthorization()
                #elseif os(macOS)
                locationManager.requestAlwaysAuthorization()
                #endif
            }
        } else {
            return locationManager.authorizationStatus
        }
    }
    
    // MARK: - UserLocationProvider
    func getUserLocationCoordinates() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                return
            }
            self.userLocationCheckedThrowingContinuation = continuation
            self.locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task.detached { [weak self] in
            guard let self else { return }
            let status = manager.authorizationStatus
            
            await MainActor.run {
                switch status {
                    case .notDetermined:
                        return
                    case .authorizedAlways, .authorizedWhenInUse, .restricted, .denied:
                        self.locationAuthorisationCheckedContinuation?.resume(returning: status)
                        self.locationAuthorisationCheckedContinuation = nil
                    @unknown default:
                        self.locationAuthorisationCheckedContinuation?.resume(returning: status)
                        self.locationAuthorisationCheckedContinuation = nil
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else {
            userLocationCheckedThrowingContinuation?.resume(throwing: LocationError.notFound)
            userLocationCheckedThrowingContinuation = nil
            return
        }
        userLocationCheckedThrowingContinuation?.resume(returning: last.coordinate)
        userLocationCheckedThrowingContinuation = nil
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        userLocationCheckedThrowingContinuation?.resume(throwing: error)
        userLocationCheckedThrowingContinuation = nil
        manager.stopUpdatingLocation()
    }
    
    deinit {
        userLocationCheckedThrowingContinuation?.resume(throwing: CancellationError())
    }
}

enum LocationError: Error {
    case notFound
    case accessNotDetermined
    case denied
}
