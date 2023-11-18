//
//  LocationCell.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 29/10/2023.
//

import SwiftUI

struct LocationCell: View {
    let location: Location
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
                        
                        Text(location.nickname)
                            .font(.system(size: 20, weight: .light))
                            .lineLimit(1)
                    }
                    
                    Text(location.fullName)
                        .lineLimit(1)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer(minLength: 8)
                
                Text((weather?.temperature.formatted(.number) ?? "--") + "°")
                    .font(.system(size: 45, weight: .ultraLight))
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.tertiary)
            
            HStack {
                Text(location.currentDateString(with: timeFormatter))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(weather?.getMinMaxTempString() ?? "-- • --")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label("1d", systemImage: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 12))
        }
        .padding([.horizontal, .top], 16)
        .padding(.bottom, 12)
        .background(
            .cellBackgroundColour(for: colorScheme)
        )
        .clipShape(.rect(cornerRadius: 16))
    }
    
    private func locationImage() -> Image {
        if isCurrentLocation {
            return Image(systemName: "location")
        } else {
            return Image(.currentLocation)
        }
    }
}

#Preview {
    LocationCell(
        location: Location(
            city: "Abuja",
            state: "FCT",
            country: "Nigeria",
            nickname: "Home",
            note: nil,
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
