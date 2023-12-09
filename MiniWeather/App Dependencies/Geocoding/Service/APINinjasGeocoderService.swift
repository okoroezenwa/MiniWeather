//
//  APINinjasGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 23/10/2023.
//

import Foundation
import CoreLocation

struct APINinjasGeocoderService: GeocoderService {
    private let parser: DataParser
    private let networkService: NetworkService
    private let apiKeysProvider: APIKeysProvider
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: APIKeysProvider) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        let locationsRequest = APINinjasGeocodingRequest(
            queryItems: ["city": searchText],
            headers: ["X-Api-Key": apiKeysProvider.getAPIKey(for: Settings.apiNinjasKey)]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [APINinjasLocation] = try parser.decode(data)
            return locations.map { Location(locationObject: $0, timeZoneIdentifier: "") }
        } catch {
            throw error
        }
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        let locationsRequest = APINinjasReverseGeocodingRequest(
            queryItems: [
                "lat": "\(coordinates.latitude)",
                "lon": "\(coordinates.longitude)"
            ],
            headers: ["X-Api-Key": apiKeysProvider.getAPIKey(for: Settings.apiNinjasKey)]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [APINinjasTemporaryLocation] = try parser.decode(data)
            return locations
                .map { APINinjasLocation(tempLocation: $0, coordinates: coordinates) }
                .map { Location(locationObject: $0, timeZoneIdentifier: "") }
        } catch {
            throw error
        }
    }
}
