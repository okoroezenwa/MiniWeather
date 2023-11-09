//
//  LocationDetailView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import SwiftUI

struct LocationDetailView: View {
    var location: Location
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    Image(colorScheme == .light ? .lightBackground : .darkBackground)
                        .resizable()
                        .ignoresSafeArea(.all)
                }
            
                Text(location.city)
        }
        .navigationTitle(location.nickname)
    }
}

#Preview {
    LocationDetailView(location: UniversalConstants.location)
}
