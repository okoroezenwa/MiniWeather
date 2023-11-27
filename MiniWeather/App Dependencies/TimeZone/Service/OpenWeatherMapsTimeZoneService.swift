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
    
    init(cache: Datastore) {
        self.cache = cache
    }
    
    func getTimeZone(for location: Location) async throws -> TimeZoneIdentifier {
        do {
            let timeZone: TimeZoneIdentifier = try cache.fetch(forKey: .timeZone(name: location.fullName))
            return timeZone
        } catch {
            throw error
        }
    }
}
