//
//  ViewModel.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 08/11/2023.
//

import Foundation
import CoreLocation

extension LocationsView {
    @Observable class ViewModel: Listener {
        let broadcaster: any Broadcaster<CLAuthorizationStatus>
        var status: CLAuthorizationStatus
        let id = UUID()
        var currentLocation: Location?
        
        init(broadcaster: any Broadcaster<CLAuthorizationStatus>) {
            self.broadcaster = broadcaster
            self.status = broadcaster.getState()
            broadcaster.register(self)
        }
        
        func update() {
            status = broadcaster.getState()
        }
    }
}
