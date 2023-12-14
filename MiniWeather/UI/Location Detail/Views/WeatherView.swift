//
//  WeatherView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import SwiftUI

struct LocationDetailViewViewModel {
    var location: Location
    let isCurrentLocation: Bool
}

struct WeatherView: View {
    let viewModel: LocationDetailViewViewModel
    @Binding var weather: WeatherProtocol?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    Image(colorScheme == .light ? .lightBackground : .darkBackground)
                        .resizable()
                        .ignoresSafeArea(.all)
                }
            
            if let weather {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                locationImage()
                                    .font(.system(size: 15, weight: .bold))
                                
                                Text(viewModel.location.nickname)
                                    .font(.system(size: 20, weight: .bold))
                                    .lineLimit(1)
                            }
                            
                            Text(viewModel.location.fullName)
                                .lineLimit(2)
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text(weather.tempString(withUnit: false))
                                    .font(.system(size: 75, weight: .light, design: .rounded))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                
                                Image(systemName: weather.symbol + ".fill")
                                    .font(.system(size: 60, weight: .light, design: .rounded))
                                    .symbolRenderingMode(.multicolor)
                            }
                            
                            HStack {
                                tempLimitView(imageName: "arrow.down", text: weather.minTempString())
                                    .padding(.trailing, 24)
                                
                                Spacer()
                                
                                tempLimitView(imageName: "arrow.up", text: weather.maxTempString())
                            }
                            .overlay {
                                Text(weather.condition)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 32)
                            .padding(.bottom, 32)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                
            }
        }
    }
    
    private func tempLimitView(imageName: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: imageName)
                .font(.system(size: 15, weight: .regular))
            
            Text(text)
        }
    }
    
    private func locationImage() -> Image {
        if viewModel.isCurrentLocation {
            return Image(systemName: "location")
        } else {
            return Image(systemName: "mappin.and.ellipse")
        }
    }
}

#Preview {
    NavigationStack {
        WeatherView(
            viewModel:
                    .init(
                        location: UniversalConstants.location,
                        isCurrentLocation: true
                    ),
            weather: .init(
                get: { UniversalConstants.weather },
                set: { _ in }
            )
        )
        .navigationTitle("Weather")
        .navigationBarTitleDisplayMode(.inline)
    }
}
