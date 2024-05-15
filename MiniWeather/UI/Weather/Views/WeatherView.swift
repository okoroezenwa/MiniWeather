//
//  WeatherView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import SwiftUI
import WeatherKit
import MapKit

struct WeatherView: View {
    let viewModel: WeatherViewModel
    @Binding var weather: WeatherProtocol?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.timeFormatter) var timeFormatter
    @AppStorage(Settings.showWeatherViewUnits) var showWeatherViewUnits = false
    @AppStorage(Settings.showWeatherViewMap) var showWeatherViewMap = false
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
                
                TemperatureCard(formattedTemperature: weather.tempString(withUnit: false), unit: showWeatherViewUnits ? weather.preferredTemperatureUnitLetter() : "", imageName: weather.symbol, items: viewModel.getTemperatureCardItems(weather))
                
                if let _ = weather.hourlyItems {
                    HourlyForecastCard(items: viewModel.getHourlyCardItems(weather))
                }
                
                if let weather = weather as? Weather {
                    if weather.availability.minuteAvailability == .available, let minuteForecast = weather.minuteForecast, !minuteForecast.isEmpty {
                        MinuteForecastCard(forecast: minuteForecast)
                    }
                    
                    DailyForecastCard(timeZone: .from(identifier: viewModel.location.timeZoneIdentifier ?? .empty), temperatureUnit: weather.preferredTemperatureUnit(), collection: weather.dailyForecast)
                }
                
                PrecipitationCard(value: weather.precipitation?.value, unit: weather.preferredMinorDistanceUnit(), items: viewModel.getPrecipitationCardItems(weather))
                
                WindAndPressureCard(value: weather.windSpeed.converted(to: weather.preferredSpeedUnit()).value, unit: weather.preferredSpeedUnit(), items: viewModel.getWindAndPressureCarditems(weather))
                
                if let visibility = weather.visibility {
                    VisibilityCard(value: visibility.converted(to: .kilometers), visibility: .visibility(from: visibility.converted(to: .meters).value), unit: .kilometers)
                }
                
                UVIndexCard(formattedValue: weather.formattedUVIndex(), category: weather.uvInfo?.category ?? "Unknown")
                
                SunAndMoonCard(
                    items: viewModel.getSunAndMoonCardItems(weather, colorScheme: colorScheme)
                ) {
                    WeatherCardGridView(
                        items: viewModel.getSunAndMoonWeatherCardItems(weather)
                    )
                }
                
                if showWeatherViewMap {
                    MapCard(location: viewModel.location)
                }
            }
            .padding(.horizontal, 16)
        }
        .safeAreaPadding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        WeatherView(
            viewModel:
                    .init(
                        location: UniversalConstants.location
                    ),
            weather: .constant(UniversalConstants.weather),
            showWeatherViewMap: false
        )
        .navigationTitle("Weather")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
