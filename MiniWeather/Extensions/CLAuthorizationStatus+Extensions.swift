//
//  CLAuthorizationStatus+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 15/11/2023.
//

import Foundation
import CoreLocation

extension CLAuthorizationStatus {
    func isAuthorised() -> Bool {
        [.authorizedAlways, .authorizedWhenInUse].contains(self)
    }
    
    func isDisallowed() -> Bool {
        [.denied, .restricted].contains(self)
    }
}
