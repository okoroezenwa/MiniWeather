//
//  UVIndexCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct UVIndexCard: View {
    private let weather: Weather
    
    init(weather: Weather) {
        self.weather = weather
    }
    
    var body: some View {
        WeatherCard(
            title: "uv index",
            imageName: "sun.max.trianglebadge.exclamationmark.fill",
            value: weather.currentWeather.uvIndex.value.formatted(),
            unit: "UVI"
        ) {
            WeatherCardTitleSubtitleView(
                title: weather.currentWeather.uvIndex.category.description,
                subtitle: (weather.currentWeather.uvIndex.category.description.lowercased() + " risk of harm from UV rays").sentenceCased
            )
        }
    }
}

//#Preview {
//    UVIndexCard()
//}
