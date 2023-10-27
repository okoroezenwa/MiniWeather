//
//  APINinjaGeodecoderService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 23/10/2023.
//

import Foundation

struct APINinjaGeodecoderService: GeocoderService {
    private let networkService: NetworkService
    private let parser: DataParser
    
    func retrieveLocations(named searchText: String) async throws -> [Location] {
        let locationsRequest = APINinjaLocationsRequest(
            queryItems: ["city": searchText],
            headers: ["X-Api-Key": "S7/jrjbcI+0knImPq9dH9Q==lNZI74iBzjtGlZjR"]
        )
        
        do {
            let data = try await networkService.getData(from: locationsRequest)
            let locations: [APINinjaLocation] = try parser.decode(data)
            return locations.map { Location(locationObject: $0, timeZoneIdentifier: "") }
        } catch {
            throw error
        }
    }
}
