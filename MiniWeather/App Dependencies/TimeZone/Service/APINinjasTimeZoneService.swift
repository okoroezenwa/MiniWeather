//
//  APINinjasTimeZoneService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

struct APINinjasTimeZoneService: TimeZoneService {
    private let parser: DataParser
    private let networkService: NetworkService
    private let apiKeysProvider: APIKeysProvider
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: APIKeysProvider) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
    }
    
    func getTimeZone(for location: Location) async throws -> TimeZoneIdentifier {
        let timeZoneRequest = APINinjasTimeZoneRequest(
            queryItems: [
                "lat": String(location.latitude),
                "lon": String(location.longitude)
            ],
            headers: ["X-Api-Key": apiKeysProvider.getAPIKey(for: Settings.apiNinjasKey)]
        )
        
        do {
            let data = try await networkService.getData(from: timeZoneRequest)
            let timeZone: TimeZoneIdentifier = try parser.decode(data)
            return timeZone
        } catch {
            throw error
        }
    }
}
