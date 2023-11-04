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
    @Environment(\.timeFormatter) var timeFormatter
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                        
                        Text(location.nickname)
                            .font(.system(size: 20, weight: .light))
                            .lineLimit(1)
                    }
                    
                    Text(location.fullName)
                        .lineLimit(1)
                        .font(.system(size: 12))
                }
                
                Spacer(minLength: 8)
                
                Text((weather?.temperature.formatted(.number) ?? "--") + "°")
                    .font(.system(size: 45, weight: .ultraLight))
            }
            
            Rectangle()
                .frame(height: 1)
            
            HStack {
                Text(location.currentDateString(with: timeFormatter))
                
                Spacer()
                
                Text(weather?.getMinMaxTempString() ?? "-- • --")
                    .font(.system(size: 12))
                
                Spacer()
                
                Label("1d", systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.system(size: 12))
        }
        .padding([.horizontal, .top], 16)
        .padding(.bottom, 12)
        .background(
            .white.opacity(0.3)
        )
        .clipShape(.rect(cornerRadius: 16))
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
            timeZone: TimeZone.gmt.identifier,
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
        )
    )
}