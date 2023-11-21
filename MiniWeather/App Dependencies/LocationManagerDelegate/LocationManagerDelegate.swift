//
//  LocationManagerDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 11/11/2023.
//

import Foundation
import CoreLocation

/// An object that can return user location authorisation and the user's current location.
protocol LocationManagerDelegate: CLLocationManagerDelegate, UserLocationAuthorisationProvider, UserLocationProvider { }
