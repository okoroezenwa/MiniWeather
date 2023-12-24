//
//  WeatherViewModel.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 21/12/2023.
//

import Foundation
import WeatherKit
import SwiftUI

struct WeatherViewModel {
    var location: Location
    
    func getTemperatureCardItems(_ weather: WeatherProtocol) -> [[WeatherCardGridViewItem.Model]] {
        [
            .init(imageName: "thermometer.high", value: weather.maxTempString(), header: "High"),
            .init(imageName: "thermometer.and.liquid.waves", value: weather.condition, header: "Condition"),
            .init(imageName: "thermometer.low", value: weather.minTempString(), header: "Low"),
            .init(imageName: "thermometer.variable.and.figure", value: weather.apparentTemperature.value.formatted(.number.precision(.fractionLength(0))) + weather.preferredTemperatureSymbol(), header: "Feels Like")
        ].chunked(into: 2)
    }
    
    func getHourlyCardItems(_ weather: WeatherProtocol) -> [HourlyForecastCard.Item] {
        guard let timeZone = TimeZone.from(identifier: location.timeZoneIdentifier ?? .empty) else {
            return []
        }
        return weather.getHourlyItems(in: timeZone)
    }
    
    func getSunAndMoonCardItems(_ weather: WeatherProtocol, colorScheme: ColorScheme) -> [ArcView.Item] {
        [
            (
                .init(
                    progress: weather.getCelestialBodyProgress(start: weather.sunrise, end: weather.sunset, in: .from(identifier: location.timeZoneIdentifier ?? .empty)),
                    start: weather.sunrise?.in(timeZone: .from(identifier: location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened) ?? "--",
                    end: weather.sunset?.in(timeZone: .from(identifier: location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened) ?? "--",
                    color: .yellow,
                    symbol: "sun.max.fill",
                    startDay: "Today",
                    endDay: "Today"
                )
            ),
            (
                .init(
                    progress: weather.getCelestialBodyProgress(start: weather.moonrise, end: weather.nextDayMoonset, in: .from(identifier: location.timeZoneIdentifier ?? .empty)),
                    start: weather.moonrise?.in(timeZone: .from(identifier: location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened) ?? "--",
                    end: weather.nextDayMoonset?.in(timeZone: .from(identifier: location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened) ?? "--",
                    color: colorScheme == .light ? Color.init(uiColor: .secondarySystemGroupedBackground) : .white,
                    symbol: "moon.fill",
                    startDay: "Today",
                    endDay: "Tomorrow"
                )
            )
        ]
    }
    
    func getSunAndMoonWeatherCardItems(_ weather: WeatherProtocol) -> [[WeatherCardGridViewItem.Model]] {
        [
            .init(imageName: "sunrise.fill", value: weather.civilDawn?.in(timeZone: .from(identifier: location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened) ?? "--", header: "Civil Dawn"),
            .init(imageName: "sunset.fill", value: weather.civilDusk?.in(timeZone: .from(identifier: location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened) ?? "--", header: "Civil Dusk"),
            .init(imageName: weather.moonPhase?.symbolName ?? "moon.fill", value: weather.moonPhase?.description ?? "--", header: "Moon Phase")
        ].chunked(into: 2)
    }
    
    func getWindAndPressureCarditems(_ weather: WeatherProtocol) -> [[WeatherCardGridViewItem.Model]] {
        [
            .init(imageName: "wind", value: (weather.windGust?.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))) ?? "--") + weather.preferredSpeedUnit().symbol, header: "Gusts"),
            .init(imageName: "arrow.up", value: weather.windCompassDirection?.abbreviation ?? "--", header: "Direction", angle: requiredAngle(from: weather.windDirection.converted(to: .degrees).value)),
            .init(imageName: "barometer", value: (weather.pressure?.converted(to: weather.preferredPressureUnit()).value.formatted(.number.precision(.fractionLength(0))) ?? "--") + weather.preferredPressureUnit().symbol, header: "Pressure"),
            .init(imageName: "chart.line.uptrend.xyaxis", value: weather.pressureTrend?.description ?? "--", header: "Pressure Trend")
        ].chunked(into: 2)
    }
    
    func getPrecipitationCardItems(_ weather: WeatherProtocol) -> [[WeatherCardGridViewItem.Model]] {
        [
            .init(imageName: "humidity.fill", value: weather.humidity.formatted(.percent), header: "Humidity"),
            .init(imageName: "umbrella.percent.fill", value: weather.precipitationChance?.formatted(.percent) ?? "--", header: "Chance"),
            .init(imageName: "drop.degreesign.fill", value: (weather.dewPoint?.converted(to: weather.preferredTemperatureUnit()).value.formatted(.number.precision(.fractionLength(0))) ?? "--") + weather.preferredTemperatureSymbol(), header: "Dew Point"),
            .init(imageName: "speedometer", value: (weather.precipitationIntensity?.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))) ?? "--") + weather.preferredSpeedUnit().symbol, header: "Intensity")
        ].chunked(into: 2)
    }
    
    private func requiredAngle(from angle: Double) -> Double {
        if angle < 180 {
            return angle + 180
        } else {
            return 360 - angle
        }
    }
}
