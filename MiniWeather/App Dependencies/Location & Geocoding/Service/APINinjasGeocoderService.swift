//
//  APINinjasGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 23/10/2023.
//

import Foundation
import CoreLocation

class APINinjasGeocoderService: GeocoderService {
    private let networkService: NetworkService
    private let parser: DataParser
    
    init(networkService: NetworkService, parser: DataParser) {
        self.networkService = networkService
        self.parser = parser
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        let locationsRequest = APINinjasGeocodingRequest(
            queryItems: ["city": searchText],
            headers: ["X-Api-Key": "S7/jrjbcI+0knImPq9dH9Q==lNZI74iBzjtGlZjR"]
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
            headers: ["X-Api-Key": "S7/jrjbcI+0knImPq9dH9Q==lNZI74iBzjtGlZjR"]
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
