//
//  TemperatureCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct TemperatureCard: View {
    @AppStorage(Settings.showWeatherViewUnits) var showWeatherViewUnits = false
    @Environment(\.timeFormatter) var timeFormatter
    private let formattedTemperature: String
    private let unit: String
    private let imageName: String
    private let items: [[WeatherCardGridViewItem.Model]]
    
    init(formattedTemperature: String, unit: String, imageName: String, items: [[WeatherCardGridViewItem.Model]]) {
        self.formattedTemperature = formattedTemperature
        self.unit = unit
        self.imageName = imageName
        self.items = items
    }
    
    var body: some View {
        WeatherCard(
            title: "temperature",
            imageName: imageName,
            value: formattedTemperature,
            unit: unit
        ) {
            WeatherCardGridView(
                items: items
            )
        }
    }
}

//#Preview {
//    TemperatureCard()
//}
