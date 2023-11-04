//
//  MainTimeZoneRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 27/10/2023.
//

import Foundation
import CoreLocation

class MainTimeZoneRepository: TimeZoneRepository {
    private let service: TimeZoneService
    
    init(service: TimeZoneService) {
        self.service = service
    }
    
    func getTimeZone(at coordinates: CLLocationCoordinate2D) async throws -> TimeZoneIdentifier {
        try await service.getTimeZone(at: coordinates)
    }
}