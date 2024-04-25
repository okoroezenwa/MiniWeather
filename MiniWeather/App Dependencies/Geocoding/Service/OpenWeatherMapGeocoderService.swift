//
//  OpenWeatherMapGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapGeocoderService<T: LocationProtocol & Decodable>: GeocoderService {
    private let parser: DataParser
    private let networkService: NetworkService
    private let apiKeysProvider: PreferencesProvider
    private let geocodingRequest: Request?
    private let reverseGeocodingRequest: Request?
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: PreferencesProvider, geocodingRequest: Request? = nil, reverseGeocodingRequest: Request? = nil) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
        self.geocodingRequest = geocodingRequest
        self.reverseGeocodingRequest = reverseGeocodingRequest
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        let locationsRequest = geocodingRequest ?? OpenWeatherMapGeocodingRequest(
            queryItems: [
                "q": searchText,
                "limit": "5",
                "appid": apiKeysProvider.string(forKey: Settings.openWeatherMapKey) ?? ""
            ]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [T] = try parser.decode(data)
            return locations.map { Location(locationObject: $0, timeZone: nil) }
        } catch {
            throw error
        }
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        let locationsRequest = reverseGeocodingRequest ?? OpenWeatherMapReverseGeocodingRequest(
            queryItems: [
                "lat": "\(coordinates.latitude)",
                "lon": "\(coordinates.longitude)",
                "limit": "5",
                "appid": apiKeysProvider.string(forKey: Settings.openWeatherMapKey) ?? ""
            ]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [T] = try parser.decode(data)
            return locations
                .map { Location(locationObject: $0, timeZone: nil) }
        } catch {
            throw error
        }
    }
}
