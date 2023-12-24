//
//  HourlyForecastCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct HourlyForecastCard: View {
    private let items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    var body: some View {
        WeatherCard(title: "24-hour forecast", imageName: "clock.fill", value: "8", unit: "N", showHeader: false) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Color.clear
                        .frame(width: 8)
                    
                    ForEach(items, id: \.self) { item in
                        let isNow = items.first == item
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.primary.opacity(0.1))
                            
                            VStack(spacing: 12) {
                                ZStack {
                                    Text("Now")
                                        .opacity(isNow ? 1 : 0)
                                    
                                    Text(item.time)
                                        .opacity(isNow ? 0 : 1)
                                }
                                
                                Image(unfilledSymbol: item.imageName)
                                    .symbolRenderingMode(.hierarchical)
                                
                                Text(item.temperature)
                            }
                            .padding(8)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
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
    
    struct Item: Hashable {
        let unit: UnitTemperature
        let temperatureSymbol: String
        let imageName: String
        let time: String
        let temperature: String
        let date: Date
        
        init(unit: UnitTemperature, temperatureSymbol: String, imageName: String, time: String, temperature: String, date: Date) {
            self.unit = unit
            self.temperatureSymbol = temperatureSymbol
            self.imageName = imageName
            self.time = time
            self.temperature = temperature
            self.date = date
        }
        
        init(hourWeather: HourWeather, unit: UnitTemperature, temperatureSymbol: String, timeZone: TimeZone?) {
            self.time = hourWeather.date.in(timeZone: timeZone).formatted(.dateTime.hour())
            self.unit = unit
            self.temperatureSymbol = temperatureSymbol
            self.imageName = hourWeather.symbolName
            self.temperature = hourWeather.temperature.converted(to: unit).value.formatted(.number.precision(.fractionLength(0))) + temperatureSymbol
            self.date = hourWeather.date
        }
    }
}

#warning("Organise later")
protocol HourlyItemConvertible {
    var date: Date { get }
    func asItem(unit: UnitTemperature, temperatureSymbol: String, timeZone: TimeZone) -> HourlyForecastCard.Item
}

extension HourWeather: HourlyItemConvertible {
    func asItem(unit: UnitTemperature, temperatureSymbol: String, timeZone: TimeZone) -> HourlyForecastCard.Item {
        .init(unit: unit, temperatureSymbol: temperatureSymbol, imageName: symbolName, time: date.in(timeZone: timeZone).formatted(.dateTime.hour()), temperature: temperature.converted(to: unit).value.formatted(.number.precision(.fractionLength(0))) + temperatureSymbol, date: date)
    }
}

extension WeatherForecast: HourlyItemConvertible {
    var currentTemperature: Measurement<UnitTemperature> {
        switch temperature {
            case .first(let temperature):
                return temperature
            case .second(_):
                fatalError("We should not be getting the non-current weather case here")
        }
    }
    
    var date: Date {
        Date(timeIntervalSince1970: unixTime)
    }
    
    func asItem(unit: UnitTemperature, temperatureSymbol: String, timeZone: TimeZone) -> HourlyForecastCard.Item {
        .init(unit: unit, temperatureSymbol: temperatureSymbol, imageName: getSymbol(), time: date.from(timeZone: .autoupdatingCurrent, to: timeZone).formatted(.dateTime.hour()), temperature: currentTemperature.converted(to: unit).value.formatted(.number.precision(.fractionLength(0))) + temperatureSymbol, date: date)
    }
}

extension WeatherForecast {
    func getSymbol() -> String {
        guard let title = weather.first?.title, let description = weather.first?.description else {
            return ""
        }
        switch (title, description) {
            case ("Thunderstorm", _):
                return "cloud.bolt.rain"
            case ("Drizzle", _):
                return "cloud.drizzle"
            case ("Rain", "freezing rain"),
                ("Snow", _):
                return "snowflake"
            case ("Rain", let description):
                switch description {
                    case "light rain",
                        "moderate rain":
                        return "cloud.sun.rain"
                    case "light intensity shower rain",
                        "shower rain",
                        "ragged shower rain":
                        return "cloud.rain"
                    case "heavy intensity shower rain",
                        "heavy intensity rain",
                        "very heavy rain",
                        "extreme rain":
                        return "cloud.heavyrain"
                    default:
                        return "cloud.rain"
                }
            case ("Atmosphere", let description):
                switch description {
                    case "smoke":
                        return "smoke"
                    case "haze":
                        return "sun.haze"
                    case "sand/dust whirls",
                        "dust":
                        return "sun.dust"
                    case "tornado":
                        return "tornado"
                    default:
                        return "cloud.fog"
                }
            case ("Clear", _):
                return "sun.max"
            case ("Clouds", let description):
                switch description {
                    case "few clouds":
                        return "cloud.sun"
                    case "scattered clouds":
                        return "cloud"
                    case "broken clouds",
                        "overcast clouds":
                        return "smoke"
                    default:
                        return "cloud"
                }
            default:
                return ""
        }
    }
}

//#Preview {
//    HourlyForecastCard()
//}
