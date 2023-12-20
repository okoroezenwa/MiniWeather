//
//  OpenWeatherMapTimeZoneService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 26/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapTimeZoneService: TimeZoneService {
    private let cache: Datastore
    #warning("Make a protocol for this")
    private let geocoder: CLGeocoder
    
    init(cache: Datastore, geocoder: CLGeocoder) {
        self.cache = cache
        self.geocoder = geocoder
    }
    
    func getTimeZone(for location: Location) async throws -> TimeZoneIdentifier {
        do {
            let currentService: Service = Settings.currentValue(for: Settings.weatherProvider)
            if currentService == .openWeatherMap {
                let timeZone: TimeZoneIdentifier = try cache.fetch(forKey: .timeZone(name: location.fullName))
                return timeZone
            } else {
                let placemarks = try await geocoder.reverseGeocodeLocation(.init(latitude: location.latitude, longitude: location.longitude))
                let timeZone = TimeZoneIdentifier(timeZone: placemarks.first?.timeZone)
                return timeZone
            }
        } catch {
            throw error
        }
    }
}
