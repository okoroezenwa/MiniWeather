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
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        locationImage()
                            .font(.system(size: 15, weight: .bold))
                        
                        Text(viewModel.location.nickname)
                            .font(.system(size: 20, weight: .bold))
                            .lineLimit(1)
                    }
                    
                    Text(viewModel.location.fullName)
                        .lineLimit(2)
                        .font(.system(size: 15, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    Text(viewModel.location.currentDateString(with: timeFormatter))
                        .font(.system(size: 13, weight: .semibold))
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                temperatureView(weather)
                    .padding(.bottom, 16)
                
                VStack(spacing: 16) {
                    if showWeatherViewMap {
                        mapView()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                    
                    if let weather = weather as? Weather {
                        
                        precipitationView(weather)
                        
                        visibilityView(weather)
                        
                        uvIndexview(weather)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func tempLimitView(imageName: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: imageName)
                .font(.system(size: 15, weight: .regular))
            
            Text(text)
        }
    }
    
    private func temperatureView(_ weather: WeatherProtocol) -> some View {
        WeatherCard(
            title: "temperature",
            imageName: weather.symbol + ".fill",
            value: weather.tempString(withUnit: false),
            unit: showWeatherViewUnits ? weather.preferredTemperatureUnitLetter() : ""
        ) {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
                GridRow {
                    WeatherCardSubItem(imageName: "thermometer.high", title: weather.maxTempString(), subtitle: "High")
                    
                    WeatherCardSubItem(imageName: "thermometer.and.liquid.waves", title: weather.condition, subtitle: "Condition")
                }
                
                GridRow {
                    WeatherCardSubItem(imageName: "thermometer.low", title: weather.minTempString(), subtitle: "Low")
                    
                    WeatherCardSubItem(imageName: "thermometer.variable.and.figure", title: weather.apparentTemperature.value.formatted(.number.precision(.fractionLength(0))) + weather.preferredTemperatureSymbol(), subtitle: "Feels Like")
                }
            }
        }
    }
    
    private func mapView() -> some View {
        Map(
            initialPosition: .region(
                .init(
                    center: viewModel.location.coordinates(),
                    span: .init(
                        latitudeDelta: 0.5,
                        longitudeDelta: 0.5
                    )
                )
            ),
            interactionModes: []
        )
    }
    
    private func precipitationView(_ weather: Weather) -> some View {
        WeatherCard(
            title: "precipitation",
            imageName: "drop.fill",
            value: weather.hourlyForecast.first?.precipitationAmount.value.formatted(.number.precision(.fractionLength(0))) ?? "",
            unit: "mm"
        ) {
            grid(weather)
        }
    }
    
    private func visibilityView(_ weather: Weather) -> some View {
        WeatherCard(
            title: "visibility",
            imageName: "road.lanes",
            value: weather.currentWeather.visibility.converted(to: .kilometers).value.formatted(.number.precision(.fractionLength(1))),
            unit: "km"
        ) {
            let visibility = WeatherVisibility.visibility(from: weather.currentWeather.visibility.value)
            return TitleAndSubtitleCardChild(
                title: visibility.rawValue,
                subtitle: visibility.subtitle()
            )
        }
    }
    
    private func uvIndexview(_ weather: Weather) -> some View {
        WeatherCard(
            title: "uv index",
            imageName: "sun.max.trianglebadge.exclamationmark.fill",
            value: weather.currentWeather.uvIndex.value.formatted(),
            unit: "UVI"
        ) {
            TitleAndSubtitleCardChild(
                title: weather.currentWeather.uvIndex.category.description,
                subtitle: (weather.currentWeather.uvIndex.category.description.lowercased() + " risk of harm from UV rays").sentenceCased
            )
        }
    }
    
    private func grid(_ weather: Weather) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                WeatherCardSubItem(imageName: "humidity.fill", title: weather.currentWeather.humidity.formatted(.percent), subtitle: "Humidity")
                
                WeatherCardSubItem(imageName: "umbrella.fill", title: weather.hourlyForecast.first?.precipitationChance.formatted(.percent) ?? "", subtitle: "Precip. Chance")
            }
            
            GridRow {
                WeatherCardSubItem(imageName: "drop.degreesign.fill", title: weather.currentWeather.dewPoint.value.formatted(.number.precision(.fractionLength(0))) + weather.preferredTemperatureSymbol(), subtitle: "Dew Point")
                
                WeatherCardSubItem(imageName: "smoke.fill", title: weather.currentWeather.cloudCover.formatted(.percent), subtitle: "Cloud Cover")
            }
        }
    }
    
    private func locationImage() -> Image {
        if viewModel.isCurrentLocation {
            return Image(systemName: "location")
        } else {
            return Image(systemName: "mappin.and.ellipse")
        }
    }
}

struct WeatherCardSubItem: View {
    private let imageName: String
    private let title: String
    private let subtitle: String
    
    init(imageName: String, title: String, subtitle: String) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.primary.opacity(0.1))
                    .frame(square: 35)
                
                Image(systemName: imageName)
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                
                Text(subtitle)
                    .font(.system(size: 15))
            }
            
            Spacer()
        }
    }
}

struct WeatherCard<Content: View>: View {
    private var spacing: CGFloat
    private let title: String
    private let imageName: String
    private let value: String
    private let unit: String
    @ViewBuilder private let content: () -> Content
    
    init(spacing: CGFloat = 12, title: String, imageName: String, value: String, unit: String, content: @escaping () -> Content) {
        self.spacing = spacing
        self.title = title
        self.imageName = imageName
        self.value = value
        self.unit = unit
        self.content = content
    }
    
    var body: some View {
        MaterialView(spacing: spacing) {
            HStack {
                Text(title.uppercased())
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.primary.opacity(0.1))
                        .frame(square: 50)
                    
                    Image(systemName: imageName)
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 22))
                }
                
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 2) {
                        Text(value)
                            .font(.system(size: 45, weight: .regular, design: .rounded))
                        
                        Text(unit)
                            .font(.system(size: 25, weight: .semibold, design: .rounded))
                    }
                
                Spacer()
            }
            
            content()
        }
    }
}

struct TitleAndSubtitleCardChild: View {
    private let title: String
    private let subtitle: String
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(subtitle)
                    .font(
                        .system(size: 15)
                    )
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
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
            )
        )
        .navigationTitle("Weather")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

enum WeatherVisibility: String {
    case extremelyLow = "Extremely Low"
    case veryLow = "Very Low"
    case low = "Low"
    case average = "Average"
    case good = "Good"
    case excellent = "Excellent"
    
    static func visibility(from value: Double) -> Self {
        switch value {
            case let x where x < 100: 
                return .extremelyLow
            case let x where (100..<1000).contains(x):
                return .veryLow
            case let x where (1000..<2000).contains(x):
                return .low
            case let x where (2000..<5000).contains(x):
                return .average
            case let x where (5000..<8000).contains(x):
                return .good
            case let x where x >= 8000:
                return .excellent
            default: return .average
        }
    }
    
    func subtitle() -> String {
        switch self {
            case .extremelyLow, .veryLow:
                return "It is best to stay indoors until conditions improve."
            case .low:
                return "Take caution when venturing out."
            case .average:
                return "Moderate risk from moving bikes and vehicles."
            case .good, .excellent:
                return "Conditions are good to go!"
        }
    }
}
