//
//  PrecipitationCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct PrecipitationCard: View {
    private let weather: Weather
    
    init(weather: Weather) {
        self.weather = weather
    }
    
    var body: some View {
        WeatherCard(
            title: "precipitation",
            imageName: "drop.fill",
            value: weather.hourlyForecast.first?.precipitationAmount.value.formatted(.number.precision(.fractionLength(0))) ?? "",
            unit: "mm"
        ) {
            WeatherCardGridView(
                items: [
                    .init(imageName: "humidity.fill", value: weather.currentWeather.humidity.formatted(.percent), header: "Humidity"),
                    .init(imageName: "umbrella.fill", value: weather.hourlyForecast.first?.precipitationChance.formatted(.percent) ?? "", header: "Chance"),
                    .init(imageName: "drop.degreesign.fill", value: weather.currentWeather.dewPoint.converted(to: weather.preferredTemperatureUnit()).value.formatted(.number.precision(.fractionLength(0))) + weather.preferredTemperatureSymbol(), header: "Dew Point"),
                    .init(imageName: "speedometer", value: weather.currentWeather.precipitationIntensity.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))) + weather.preferredSpeedUnit().symbol, header: "Intensity")
                ].chunked(into: 2)
            )
        }
    }
}

//#Preview {
//    PrecipitationCard()
//}
