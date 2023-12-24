//
//  MinuteForecastCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct MinuteForecastCard: View {
    let forecast: Forecast<MinuteWeather>
    
    var body: some View {
        WeatherCard(title: "Minute Forecast", showHeader: false) {
            EmptyView()
        }
    }
}

//#Preview {
//    MinuteForecastCard()
//}
