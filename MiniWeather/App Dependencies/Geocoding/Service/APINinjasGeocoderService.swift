//
//  APINinjasGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 23/10/2023.
//

import Foundation
import CoreLocation

struct APINinjasGeocoderService<T: LocationProtocol & Decodable, P: PartialLocationProtocol & Decodable>: GeocoderService {
    private let parser: DataParser
    private let networkService: NetworkService
    private let apiKeysProvider: StringPreferenceProvider
    private let geocodingRequest: Request?
    private let reverseGeocodingRequest: Request?
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: StringPreferenceProvider, geocodingRequest: Request? = nil, reverseGeocodingRequest: Request? = nil) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
        self.geocodingRequest = geocodingRequest
        self.reverseGeocodingRequest = reverseGeocodingRequest
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        let locationsRequest = geocodingRequest ?? APINinjasGeocodingRequest(
            queryItems: ["city": searchText],
            headers: ["X-Api-Key": apiKeysProvider.string(forKey: Settings.apiNinjasKey) ?? ""]
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
        let locationsRequest = reverseGeocodingRequest ?? APINinjasReverseGeocodingRequest(
            queryItems: [
                "lat": "\(coordinates.latitude)",
                "lon": "\(coordinates.longitude)"
            ],
            headers: ["X-Api-Key": apiKeysProvider.string(forKey: Settings.apiNinjasKey) ?? ""]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [P] = try parser.decode(data)
            return locations
                .map { APINinjasLocation(tempLocation: $0, coordinates: coordinates) }
                .map { Location(locationObject: $0, timeZone: nil) }
        } catch {
            throw error
        }
    }
}
