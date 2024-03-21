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
    private let apiKeysProvider: StringPreferenceProvider
    private let timeZoneRequest: Request?
    
    init(parser: DataParser, networkService: NetworkService, apiKeysProvider: StringPreferenceProvider, timeZoneRequest: Request? = nil) {
        self.parser = parser
        self.networkService = networkService
        self.apiKeysProvider = apiKeysProvider
        self.timeZoneRequest = timeZoneRequest
    }
    
    func getTimeZone(for location: Location) async throws -> TimeZoneIdentifier {
        let timeZoneRequest = timeZoneRequest ?? APINinjasTimeZoneRequest(
            queryItems: [
                "lat": String(location.latitude),
                "lon": String(location.longitude)
            ],
            headers: ["X-Api-Key": apiKeysProvider.string(forKey: Settings.apiNinjasKey) ?? ""]
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
