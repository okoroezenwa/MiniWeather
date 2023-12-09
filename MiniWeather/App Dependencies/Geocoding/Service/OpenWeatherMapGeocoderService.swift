//
//  OpenWeatherMapGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapGeocoderService: GeocoderService {
    private let parser: DataParser
    private let networkService: NetworkService
    private let apiKeysProvider: APIKeysProvider
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: APIKeysProvider) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        let locationsRequest = OpenWeatherMapGeocodingRequest(
            queryItems: [
                "q": searchText,
                "limit": "5",
                "appid": apiKeysProvider.getAPIKey(for: Settings.openWeatherMapKey)
            ]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [OpenWeatherMapLocation] = try parser.decode(data)
            return locations.map { Location(locationObject: $0, timeZoneIdentifier: "") }
        } catch {
            throw error
        }
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        let locationsRequest = OpenWeatherMapReverseGeocodingRequest(
            queryItems: [
                "lat": "\(coordinates.latitude)",
                "lon": "\(coordinates.longitude)",
                "limit": "5",
                "appid": apiKeysProvider.getAPIKey(for: Settings.openWeatherMapKey)
            ]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [OpenWeatherMapLocation] = try parser.decode(data)
            return locations
                .map { Location(locationObject: $0, timeZoneIdentifier: "") }
        } catch {
            throw error
        }
    }
}
