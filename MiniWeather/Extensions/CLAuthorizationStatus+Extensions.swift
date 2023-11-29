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
#if os(iOS)
        [.authorizedAlways, .authorizedWhenInUse].contains(self)
#elseif os(macOS)
        [.authorized, .authorizedAlways].contains(self)
#endif
    }
    
    func isDisallowed() -> Bool {
        [.denied, .restricted].contains(self)
    }
}
