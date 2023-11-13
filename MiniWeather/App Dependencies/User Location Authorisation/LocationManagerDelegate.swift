//
//  LocationManagerDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 11/11/2023.
//

import Foundation
import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    
    
    override init() {
        super.init()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard case let status = manager.authorizationStatus, status != .notDetermined else { return }
        
    }
}
