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
            VStack(spacing: 16) {
                temperatureView(weather)
                    .padding(.top, 16)
                
                if let weather = weather as? Weather {
                    hourlyForecastView(weather)
                    
                    precipitationView(weather)
                    
                    windAndPressureView(weather)
                    
                    visibilityView(weather)
                    
                    uvIndexview(weather)
                    
                    sunAndMoonView(weather)
                }
                
                if showWeatherViewMap {
                    mapView()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 5)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func temperatureView(_ weather: WeatherProtocol) -> some View {
        WeatherCard(
            title: "temperature",
            subtitle: viewModel.location.currentDateString(with: timeFormatter),
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
        }
    }
    
    private func hourlyForecastView(_ weather: Weather) -> some View {
        WeatherCard(title: "24-hour forecast", imageName: "clock.fill", value: "8", unit: "N", showHeader: false) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Color.clear
                        .frame(width: 8)
                    
                    if let firstIndex = weather.hourlyForecast.firstIndex(where: { Calendar.autoupdatingCurrent.isDate($0.date, equalTo: .now.convert(from: viewModel.location.timeZone ?? .autoupdatingCurrent, to: .autoupdatingCurrent), toGranularity: .hour) }),
                        case let collection = weather.hourlyForecast[firstIndex...(firstIndex + 24)] {
                        ForEach(collection, id: \.date) { forecast in
                            let isNow = collection.firstIndex(of: forecast) == firstIndex
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.primary.opacity(0.1))
                                
                                VStack(spacing: 12) {
                                    Text(isNow ? "Now" : forecast.date.formatted(.dateTime.hour()))
                                        .font(.system(size: 13, weight: .medium))
                                    
                                    Image(unfilledSymbol: isNow ? weather.symbol : forecast.symbolName)
                                        .symbolRenderingMode(.hierarchical)
                                        .font(.system(size: 13, weight: .medium))
                                    
                                    Text((isNow ? weather.temperature : forecast.temperature).converted(to: weather.preferredTemperatureUnit()).value.formatted(.number.precision(.fractionLength(0))) + weather.preferredTemperatureSymbol())
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .padding(8)
                            }
                        }
                    }
                    
                    Color.clear
                        .frame(width: 8)
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, -16)
        }
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
    
    private func windAndPressureView(_ weather: Weather) -> some View {
        WeatherCard(
            title: "wind & pressure",
            imageName: "fan.fill",
            value: weather.currentWeather.wind.speed.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))),
            unit: weather.preferredSpeedUnit().symbol
        ) {
            WeatherCardGridView(
                items: [
                    .init(imageName: "wind", value: (weather.currentWeather.wind.gust?.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))) ?? "--") + weather.preferredSpeedUnit().symbol, header: "Gusts"),
                    .init(imageName: "arrow.up", value: weather.currentWeather.wind.compassDirection.abbreviation, header: "Direction", angle: weather.currentWeather.wind.direction.converted(to: .degrees).value),
                    .init(imageName: "barometer", value: weather.currentWeather.pressure.converted(to: weather.preferredPressureUnit()).value.formatted(.number.precision(.fractionLength(0))) + weather.preferredPressureUnit().symbol, header: "Pressure"),
                    .init(imageName: "chart.line.uptrend.xyaxis", value: weather.currentWeather.pressureTrend.description, header: "Pressure Trend")
                ].chunked(into: 2)
            )
        }
    }
    
    private func sunAndMoonView(_ weather: Weather) -> some View {
        WeatherCard(
            title: "sun & moon",
            imageName: "",
            value: weather.currentWeather.wind.speed.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))),
            unit: weather.preferredSpeedUnit().symbol,
            showHeader: false
        ) {
            EmptyView()
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
        WeatherCardGridView(
            items: [
                .init(imageName: "humidity.fill", value: weather.currentWeather.humidity.formatted(.percent), header: "Humidity"),
                .init(imageName: "umbrella.fill", value: weather.hourlyForecast.first?.precipitationChance.formatted(.percent) ?? "", header: "Chance"),
                .init(imageName: "drop.degreesign.fill", value: weather.currentWeather.dewPoint.converted(to: weather.preferredTemperatureUnit()).value.formatted(.number.precision(.fractionLength(0))) + weather.preferredTemperatureSymbol(), header: "Dew Point"),
                .init(imageName: "speedometer", value: weather.currentWeather.precipitationIntensity.converted(to: weather.preferredSpeedUnit()).value.formatted(.number.precision(.fractionLength(1))) + weather.preferredSpeedUnit().symbol, header: "Intensity")
            ].chunked(into: 2)
        )
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
    
    private func locationImage() -> Image {
        if viewModel.isCurrentLocation {
            return Image(systemName: "location")
        } else {
            return Image(systemName: "mappin.and.ellipse")
        }
    }
}

struct WeatherCard<Content: View>: View {
    private var spacing: CGFloat
    private let title: String
    private let subtitle: String?
    private let imageName: String
    private let value: String
    private let unit: String
    private let showHeader: Bool
    @ViewBuilder private let content: () -> Content
    
    init(spacing: CGFloat = 12, title: String, subtitle: String? = nil, imageName: String, value: String, unit: String, showHeader: Bool = true, content: @escaping () -> Content) {
        self.spacing = spacing
        self.title = title
        self.imageName = imageName
        self.value = value
        self.unit = unit
        self.showHeader = showHeader
        self.content = content
        self.subtitle = subtitle
    }
    
    var body: some View {
        MaterialView(spacing: spacing) {
            HStack {
                Text(title.uppercased())
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                
                Spacer()
                
                if let subtitle {
                    Text(subtitle.uppercased())
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                }
            }
            
            if showHeader {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.primary.opacity(0.1))
                            .frame(square: 50)
                        
                        Image(unfilledSymbol: imageName)
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 24))
                    }
                    
                    HStack(
                        alignment: .firstTextBaseline,
                        spacing: 2) {
                            Text(value)
                                .font(.system(size: 45, weight: .regular, design: .rounded))
                            
                            Text(unit)
                                .font(.system(size: 25, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    
                    Spacer()
                }
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

struct WeatherCardGridView: View {
    private let items: [[Item]]
    
    init(items: [[Item]]) {
        self.items = items
    }
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            ForEach(items, id: \.self) { subItems in
                GridRow {
                    ForEach(subItems) { item in
                        WeatherCardSubItem(item: item)
                    }
                }
            }
        }
    }
}

extension WeatherCardGridView {
    struct Item: Hashable, Identifiable {
        let imageName: String
        let value: String
        let header: String
        let angle: Double?
        let id = UUID()
        
        init(imageName: String, value: String, header: String, angle: Double? = nil) {
            self.imageName = imageName
            self.value = value
            self.header = header
            self.angle = angle
        }
    }
}

struct WeatherCardSubItem: View {
    private let item: WeatherCardGridView.Item
    
    init(item: WeatherCardGridView.Item) {
        self.item = item
    }
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.primary.opacity(0.1))
                    .frame(square: 35)
                
                Image(systemName: item.imageName)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 18))
                    .visualEffect { content, _ in
                        content
                            .rotationEffect(.degrees(item.angle ?? 0))
                    }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.header)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                Text(item.value)
                    .font(.system(size: 15, weight: .semibold))
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
            ),
            showWeatherViewMap: false
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
