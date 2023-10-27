//
//  TimeZoneService.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

protocol TimeZoneService {
    func getTimeZone(at coordinates: CLLocationCoordinate2D) async throws -> TimeZoneIdentifier
}

class APINinjaTimeZoneService: TimeZoneService {
    let networkService: NetworkService
    let parser: DataParser
    
    init(networkService: NetworkService, parser: DataParser) {
        self.networkService = networkService
        self.parser = parser
    }
    
    func getTimeZone(at coordinates: CLLocationCoordinate2D) async throws -> TimeZoneIdentifier {
        let timeZoneRequest = APINinjaTimeZoneRequest(
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
