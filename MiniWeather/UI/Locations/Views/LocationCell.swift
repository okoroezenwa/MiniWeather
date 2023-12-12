//
//  LocationCell.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 29/10/2023.
//

import SwiftUI

struct LocationCell: View {
    @Environment(\.timeFormatter) private var timeFormatter
    @AppStorage(Settings.unitsOfMeasure) private var unitOfMeasure = UnitOfMeasure.default
    private let location: Location?
    private let weather: WeatherProtocol?
    private let isCurrentLocation: Bool
    private let shouldDisplayAsLoading: Bool
    
    init(location: Location?, weather: WeatherProtocol?, isCurrentLocation: Bool, shouldDisplayAsLoading: Bool) {
        self.location = location
        self.weather = weather
        self.isCurrentLocation = isCurrentLocation
        self.shouldDisplayAsLoading = shouldDisplayAsLoading
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    locationImage()
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(square: 15)
                        .foregroundStyle(!shouldDisplayAsLoading ? .primary : .quaternary)
                    
                    Text(location?.nickname ?? "Location Name")
                        .foregroundStyle(!shouldDisplayAsLoading ? .primary : .quaternary)
                        .font(.system(size: 20, weight: .light))
                        .lineLimit(1)
                }
                
                Text(location?.fullName ?? "Location Details")
                        .lineLimit(1)
                    .font(.system(size: 12))
                    .foregroundStyle(!shouldDisplayAsLoading ? .secondary : .quaternary)
            }
            
            Spacer(minLength: 8)
            
            Text(weather?.tempString() ?? "--")
                .foregroundStyle(!shouldDisplayAsLoading ? .primary : .quaternary)
                .font(.system(size: 45, weight: .ultraLight))
        }
        
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(!shouldDisplayAsLoading ? .tertiary : .quaternary)
        
        HStack {
            Text(location?.currentDateString(with: timeFormatter) ?? "--:--")
                .foregroundStyle(!shouldDisplayAsLoading ? .secondary : .quaternary)
            
            Spacer()
            
            if let weather, !weather.symbol.isEmpty {
                Image(systemName: weather.symbol + ".fill")
                    .font(.system(size: 16))
                    .padding(.trailing, 4)
                    .symbolRenderingMode(.multicolor)
            } else {
                Text("--")
            }
        }
        .overlay {
            Text(weather?.getMinMaxTempString() ?? "-- • --")
                .font(.system(size: 12))
                .foregroundStyle(!shouldDisplayAsLoading ? .secondary : .quaternary)
        }
        .font(.system(size: 12))
        .id(unitOfMeasure)
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
        location: UniversalConstants.location,
        weather: UniversalConstants.weather,
        isCurrentLocation: true,
        shouldDisplayAsLoading: false
    )
}
