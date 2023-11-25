//
//  OpenWeatherMapsGeocoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/11/2023.
//

import Foundation
import CoreLocation

struct OpenWeatherMapsGeocoderService: GeocoderService {
    private let networkService: NetworkService
    private let parser: DataParser
    
    init(networkService: NetworkService, parser: DataParser) {
        self.networkService = networkService
        self.parser = parser
    }
    
    func getLocations(named searchText: String) async throws -> [Location] {
        let locationsRequest = OpenWeatherMapsGeocodingRequest(
            queryItems: [
                "q": searchText,
                "appid": "b70953dbe7338b90a67f650598d6e321"
            ]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [OpenWeatherMapsLocation] = try parser.decode(data)
            return locations.map { Location(locationObject: $0, timeZoneIdentifier: "") }
        } catch {
            throw error
        }
    }
    
    func getLocations(at coordinates: CLLocationCoordinate2D) async throws -> [Location] {
        let locationsRequest = OpenWeatherMapsReverseGeocodingRequest(
            queryItems: [
                "lat": "\(coordinates.latitude)",
                "lon": "\(coordinates.longitude)",
                "appid": "b70953dbe7338b90a67f650598d6e321",
                "limit": "1"
            ]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [OpenWeatherMapsLocation] = try parser.decode(data)
            return locations
                .map { Location(locationObject: $0, timeZoneIdentifier: "") }
        } catch {
            throw error
        }
    }
}
