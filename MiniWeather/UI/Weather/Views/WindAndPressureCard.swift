//
//  WindAndPressureCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct WindAndPressureCard: View {
    private let weather: Weather
    
    init(weather: Weather) {
        self.weather = weather
    }
    
    var body: some View {
        WeatherCard(
            title: "wind & pressure",
            imageName: "fan.fill",
            value: weather.currentWeather.wind.speed.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))),
            unit: weather.preferredSpeedUnit().symbol
        ) {
            WeatherCardGridView(
                items: [
                    .init(imageName: "wind", value: (weather.currentWeather.wind.gust?.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))) ?? "--") + weather.preferredSpeedUnit().symbol, header: "Gusts"),
                    .init(imageName: "arrow.up", value: weather.currentWeather.wind.compassDirection.abbreviation, header: "Direction", angle: requiredAngle(from: weather.currentWeather.wind.direction.converted(to: .degrees).value)),
                    .init(imageName: "barometer", value: weather.currentWeather.pressure.converted(to: weather.preferredPressureUnit()).value.formatted(.number.precision(.fractionLength(0))) + weather.preferredPressureUnit().symbol, header: "Pressure"),
                    .init(imageName: "chart.line.uptrend.xyaxis", value: weather.currentWeather.pressureTrend.description, header: "Pressure Trend")
                ].chunked(into: 2)
            )
        }
    }
    
    private func requiredAngle(from angle: Double) -> Double {
        if angle < 180 {
            return angle + 180
        } else {
            return 360 - angle
        }
    }
}

//#Preview {
//    WindAndPressureCard()
//}
