//
//  LocationManagerDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 11/11/2023.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    var responder: LocationManagerDelegateResponder? { get set }
    func getAuthorisationStatus() -> CLAuthorizationStatus
}

class MainLocationManagerDelegate: NSObject, LocationManagerDelegate, CLLocationManagerDelegate {
    weak var responder: LocationManagerDelegateResponder?
    private var locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        requestAuthorisation()
    }
    
    private func requestAuthorisation() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getAuthorisationStatus() -> CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard case let status = manager.authorizationStatus, status != .notDetermined else { return }
        responder?.locationAuthorisationChanged(to: status)
    }
}
