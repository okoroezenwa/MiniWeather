//
//  LocationCell.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 29/10/2023.
//

import SwiftUI

struct LocationCell: View {
    let location: Location?
    let weather: Weather?
    let isCurrentLocation: Bool
    @Environment(\.timeFormatter) var timeFormatter
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        locationImage()
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(square: 15)
                            .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .primary : .quaternary)
                        
                        Text(location?.nickname ?? "Location Name")
                            .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .primary : .quaternary)
                            .font(.system(size: 20, weight: .light))
                            .lineLimit(1)
                    }
                    
                    Text(location?.fullName ?? "Location Details")
                        .lineLimit(1)
                        .font(.system(size: 12))
                        .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .secondary : .quaternary)
                }
                
                Spacer(minLength: 8)
                
                Text((weather?.temperature.formatted(.number) ?? "--") + "°")
                    .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .primary : .quaternary)
                    .font(.system(size: 45, weight: .ultraLight))
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .tertiary : .quaternary)
            
            HStack {
                Text(location?.currentDateString(with: timeFormatter) ?? "--:--")
                    .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .secondary : .quaternary)
                
                Spacer()
                
                Text(weather?.getMinMaxTempString() ?? "-- • --")
                    .font(.system(size: 12))
                    .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .secondary : .quaternary)
                
                Spacer()
                
                Label("1d", systemImage: "arrow.triangle.2.circlepath")
                    .foregroundStyle(isWithinCurrentLocationCacheTimeLimit() ? .secondary : .quaternary)
            }
            .font(.system(size: 12))
        }
        .padding([.horizontal, .top], 16)
        .padding(.bottom, 12)
        .background(
            .cellBackgroundColour(for: colorScheme)
        )
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private func locationImage() -> Image {
        if isCurrentLocation {
            return Image(systemName: "location")
        } else {
            return Image(.currentLocation)
        }
    }
    
    private func isWithinCurrentLocationCacheTimeLimit() -> Bool {
        guard isCurrentLocation else {
            return true
        }
        guard let location else {
            return false
        }
        return !location.isOutdated()
    }
}

#Preview {
    LocationCell(
        location: Location(
            city: "Abuja",
            state: "FCT",
            country: "Nigeria",
            nickname: "Home",
            timeZone: TimeZone.autoupdatingCurrent.identifier,
            latitide: 0,
            longitude: 0
        ),
        weather: Weather(
            temperature: 20,
            feelsLike: 19,
            minimumTemperature: 16,
            maximumTemperature: 23,
            humidity: 87,
            windSpeed: 10,
            windDegrees: 210,
            sunrise: 1615616341,
            sunset: 1615658463,
            cloudPercentage: 75
        ),
        isCurrentLocation: true
    )
}
