//
//  OpenWeatherMapTimeZoneService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 26/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapTimeZoneService<T: TimeZoneLocationProtocol>: TimeZoneService {
    private let cache: Datastore
    private let geocoder: TimeZoneLocationGeocoder
    private let weatherService: Service
    
    init(cache: Datastore, geocoder: TimeZoneLocationGeocoder, weatherService: Service) {
        self.cache = cache
        self.geocoder = geocoder
        self.weatherService = weatherService
    }
    
    func getTimeZone(for location: Location) async throws -> TimeZoneIdentifier {
        do {
            if weatherService == .openWeatherMap {
                let timeZone: TimeZoneIdentifier = try cache.fetch(forKey: .timeZone(name: location.fullName))
                return timeZone
            } else {
                let placemarks: [T] = try await geocoder.getLocations(at: .init(latitude: location.latitude, longitude: location.longitude))
                let timeZone = TimeZoneIdentifier(timeZone: placemarks.first?.timeZone)
                return timeZone
            }
        } catch {
            throw error
        }
    }
}
