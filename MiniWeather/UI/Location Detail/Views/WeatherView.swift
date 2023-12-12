//
//  WeatherView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import SwiftUI

struct LocationDetailViewViewModel {
    var location: Location
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
            
            Text(weather?.tempString(withUnit: true) ?? "--")
                .font(.system(size: 200, weight: .light, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

#Preview {
    WeatherView(
        viewModel:
            .init(
                location: UniversalConstants.location
            ),
        weather: .init(
            get: { UniversalConstants.weather },
            set: { _ in }
        )
    )
}
