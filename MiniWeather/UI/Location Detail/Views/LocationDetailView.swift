//
//  LocationDetailView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import SwiftUI

struct LocationDetailView: View {
    var location: Location
    @Binding var weather: Weather?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    Image(colorScheme == .light ? .lightBackground : .darkBackground)
                        .resizable()
                        .ignoresSafeArea(.all)
                }
            
            Text((weather?.tempString() ?? "--") + "°")
                .font(.system(size: 200, weight: .light, design: .rounded))
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Details")
    }
}

#Preview {
    LocationDetailView(
        location: UniversalConstants.location,
        weather: .init(
            get: { nil },
            set: { _ in }
        )
    )
}
