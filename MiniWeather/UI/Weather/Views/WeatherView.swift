//
//  WeatherView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import SwiftUI
import WeatherKit
import MapKit

struct LocationDetailViewViewModel {
    var location: Location
    let isCurrentLocation: Bool
}

struct WeatherView: View {
    let viewModel: LocationDetailViewViewModel
    @Binding var weather: WeatherProtocol?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.timeFormatter) var timeFormatter
    @AppStorage(Settings.showWeatherViewUnits) var showWeatherViewUnits = false
    @AppStorage(Settings.showWeatherViewMap) var showWeatherViewMap = true
    @State private var selectedAlert: WeatherAlert?
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    Image(colorScheme == .light ? .lightBackground : .darkBackground)
                        .resizable()
                        .ignoresSafeArea(.all)
                }
            
            if let weather {
                mainView(weather)
            } else {
                Text("--")
                    .font(.system(size: 200, weight: .light, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
    
    private func mainView(_ weather: WeatherProtocol) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if let weather = weather as? Weather, weather.availability.alertAvailability == .available, let alerts = weather.weatherAlerts, !alerts.isEmpty {
                    AlertCard(alerts: alerts)
                }
                
                TemperatureCard(weather: weather, location: viewModel.location)
                
                if let weather = weather as? Weather {
                    HourlyForecastCard(items: getHourlyItems(weather))
                    
                    if weather.availability.minuteAvailability == .available, let minuteForecast = weather.minuteForecast, !minuteForecast.isEmpty {
                        MinuteForecastCard(forecast: minuteForecast)
                    }
                    
                    DailyForecastCard(timeZone: .from(identifier: viewModel.location.timeZoneIdentifier ?? .empty), temperatureUnit: weather.preferredTemperatureUnit(), collection: weather.dailyForecast)
                    
                    PrecipitationCard(weather: weather)
                    
                    WindAndPressureCard(weather: weather)
                    
                    VisibilityCard(weather: weather)
                    
                    UVIndexCard(weather: weather)
                    
                    SunAndMoonCard(weather: weather)
                }
                
                if showWeatherViewMap {
                    MapCard(location: viewModel.location)
                }
            }
            .padding(.horizontal, 16)
        }
        .safeAreaPadding(.top, 16)
    }
    
    private func getHourlyItems(_ weather: Weather) -> [HourlyForecastCard.Item] {
        guard let firstIndex = weather.hourlyForecast.firstIndex(where: { Calendar.autoupdatingCurrent.isDate($0.date, equalTo: .now, toGranularity: .hour) }) else {
            return []
        }
        
        var items = weather.hourlyForecast[firstIndex...(firstIndex + 24)].map{ HourlyForecastCard.Item(hourWeather: $0, unit: weather.preferredTemperatureUnit(), temperatureSymbol: weather.preferredTemperatureSymbol(), timeZone: .from(identifier: viewModel.location.timeZoneIdentifier ?? .empty), isForecast: true) }
        
        if let date = weather.sunrise, let index = items.firstIndex(where: { Calendar.autoupdatingCurrent.isDate(date, equalTo: $0.date, toGranularity: .hour) }) {
            let indexAfter = items.index(after: index)
            let item = HourlyForecastCard.Item(unit: weather.preferredTemperatureUnit(), temperatureSymbol: weather.preferredTemperatureSymbol(), imageName: "sunrise", title: date.in(timeZone: .from(identifier: viewModel.location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened), bottomText: "Sunrise", isForecast: false, date: date)
            items.insert(item, at: indexAfter)
        }
        
        if let date = weather.sunset, let index = items.firstIndex(where: { Calendar.autoupdatingCurrent.isDate(date, equalTo: $0.date, toGranularity: .hour) }) {
            let indexAfter = items.index(after: index)
            let item = HourlyForecastCard.Item(unit: weather.preferredTemperatureUnit(), temperatureSymbol: weather.preferredTemperatureSymbol(), imageName: "sunset", title: date.in(timeZone: .from(identifier: viewModel.location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened), bottomText: "Sunset", isForecast: false, date: date)
            items.insert(item, at: indexAfter)
        }
        
        if let first = weather.dailyForecast.first(where: { Calendar.autoupdatingCurrent.isDateInTomorrow($0.date) }) {
            if let date = first.sun.sunrise, let index = items.firstIndex(where: { Calendar.autoupdatingCurrent.isDate(date, equalTo: $0.date, toGranularity: .hour) }) {
                let indexAfter = items.index(after: index)
                let item = HourlyForecastCard.Item(unit: weather.preferredTemperatureUnit(), temperatureSymbol: weather.preferredTemperatureSymbol(), imageName: "sunrise", title: date.in(timeZone: .from(identifier: viewModel.location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened), bottomText: "Sunrise", isForecast: false, date: date)
                items.insert(item, at: indexAfter)
            }
            
            if let date = first.sun.sunset, let index = items.firstIndex(where: { Calendar.autoupdatingCurrent.isDate(date, equalTo: $0.date, toGranularity: .hour) }) {
                let indexAfter = items.index(after: index)
                let item = HourlyForecastCard.Item(unit: weather.preferredTemperatureUnit(), temperatureSymbol: weather.preferredTemperatureSymbol(), imageName: "sunset", title: date.in(timeZone: .from(identifier: viewModel.location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened), bottomText: "Sunset", isForecast: false, date: date)
                items.insert(item, at: indexAfter)
            }
        }
        
        return items
    }
}

#Preview {
    NavigationStack {
        WeatherView(
            viewModel:
                    .init(
                        location: UniversalConstants.location,
                        isCurrentLocation: true
                    ),
            weather: .init(
                get: { UniversalConstants.weather },
                set: { _ in }
            ),
            showWeatherViewMap: false
        )
        .navigationTitle("Weather")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
