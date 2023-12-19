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
    private let weather: WeatherProtocol
    private let location: Location
    
    init(weather: WeatherProtocol, location: Location) {
        self.weather = weather
        self.location = location
    }
    
    var body: some View {
        WeatherCard(
            title: "temperature",
            imageName: weather.symbol,
            value: weather.tempString(withUnit: false),
            unit: showWeatherViewUnits ? weather.preferredTemperatureUnitLetter() : ""
        ) {
            WeatherCardGridView(
                items: [
                    .init(imageName: "thermometer.high", value: weather.maxTempString(), header: "High"),
                    .init(imageName: "thermometer.and.liquid.waves", value: weather.condition, header: "Condition"),
                    .init(imageName: "thermometer.low", value: weather.minTempString(), header: "Low"),
                    .init(imageName: "thermometer.variable.and.figure", value: weather.apparentTemperature.value.formatted(.number.precision(.fractionLength(0))) + weather.preferredTemperatureSymbol(), header: "Feels Like")
                ].chunked(into: 2)
            )
        } trailingHeaderView: {
            WeatherCardTrailingHeaderTextView(text: location.currentDateString(with: timeFormatter))
        }
    }
}

//#Preview {
//    TemperatureCard()
//}
