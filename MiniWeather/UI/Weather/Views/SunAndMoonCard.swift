//
//  SunAndMoonCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct SunAndMoonCard: View {
    private let weather: Weather
    
    init(weather: Weather) {
        self.weather = weather
    }
    
    var body: some View {
        WeatherCard(
            title: "sun & moon",
            showHeader: false
        ) {
            EmptyView()
        }
    }
}

//#Preview {
//    SunAndMoonCard()
//}
