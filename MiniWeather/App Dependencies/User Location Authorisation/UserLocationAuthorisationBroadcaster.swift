//
//  UserLocationAuthorisationBroadcaster.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import Foundation
import CoreLocation

class UserLocationAuthorisationBroadcaster: NSObject, CLLocationManagerDelegate, Broadcaster {
    private let locationManager: CLLocationManager
    private var state: CLAuthorizationStatus
    private var observers = [Listener]()
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        self.state = locationManager.authorizationStatus
        super.init()
        self.locationManager.delegate = self
        requestAuthorisation()
    }
    
    private func requestAuthorisation() {
        if state == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getState() -> CLAuthorizationStatus {
        state
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard case let status = manager.authorizationStatus, status != .notDetermined else { return }
        state = status
        notifyObservers()
    }
    
    func register(_ observer: any Listener) {
        guard !observers.contains(where: { $0.id == observer.id }) else { return }
        observers.append(observer)
    }
    
    func unregister(_ observer: any Listener) {
        observers.removeAll { $0.id == observer.id }
    }
    
    func notifyObservers() {
        observers.forEach { observer in
            observer.update()
        }
    }
}
