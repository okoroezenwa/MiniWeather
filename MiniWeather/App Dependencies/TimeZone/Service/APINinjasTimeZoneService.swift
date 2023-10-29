//
//  APINinjasTimeZoneService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

class APINinjasTimeZoneService: TimeZoneService {
    private let networkService: NetworkService
    private let parser: DataParser
    
    init(networkService: NetworkService, parser: DataParser) {
        self.networkService = networkService
        self.parser = parser
    }
    
    func getTimeZone(at coordinates: CLLocationCoordinate2D) async throws -> TimeZoneIdentifier {
        let timeZoneRequest = APINinjasTimeZoneRequest(
            queryItems: [
                "lon": coordinates.longitude,
                "lat": coordinates.latitude
            ],
            headers: ["X-Api-Key": "S7/jrjbcI+0knImPq9dH9Q==lNZI74iBzjtGlZjR"]
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
