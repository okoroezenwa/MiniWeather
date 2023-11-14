//
//  UserLocationAuthorisationBroadcaster.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegateResponder: AnyObject {
    func locationAuthorisationChanged(to status: CLAuthorizationStatus)
}

class UserLocationAuthorisationBroadcaster: NSObject, CLLocationManagerDelegate, Broadcaster, LocationManagerDelegateResponder {
    private let locationManagerDelegate: LocationManagerDelegate
    private var observers = [Listener]()
    
    init(locationManagerDelegate: LocationManagerDelegate) {
        self.locationManagerDelegate = locationManagerDelegate
        super.init()
        self.locationManagerDelegate.responder = self
    }
    
    func getState() -> CLAuthorizationStatus {
        locationManagerDelegate.getAuthorisationStatus()
    }
    
    func locationAuthorisationChanged(to status: CLAuthorizationStatus) {
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
