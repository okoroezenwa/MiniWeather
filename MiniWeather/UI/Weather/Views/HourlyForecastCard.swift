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
                                    
                                    Text(item.title)
                                        .opacity(isNow ? 0 : 1)
                                }
                                
                                Image(unfilledSymbol: item.imageName)
                                    .symbolRenderingMode(.hierarchical)
                                
                                Text(item.bottomText)
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
        let title: String
        let bottomText: String
        let isForecast: Bool
        let date: Date
        
        init(unit: UnitTemperature, temperatureSymbol: String, imageName: String, title: String, bottomText: String, isForecast: Bool, date: Date) {
            self.unit = unit
            self.temperatureSymbol = temperatureSymbol
            self.imageName = imageName
            self.title = title
            self.bottomText = bottomText
            self.isForecast = isForecast
            self.date = date
        }
        
        init(hourWeather: HourWeather, unit: UnitTemperature, temperatureSymbol: String, timeZone: TimeZone?, isForecast: Bool) {
            self.title = hourWeather.date.in(timeZone: timeZone).formatted(.dateTime.hour())
            self.unit = unit
            self.temperatureSymbol = temperatureSymbol
            self.imageName = hourWeather.symbolName
            self.isForecast = isForecast
            self.bottomText = hourWeather.temperature.converted(to: unit).value.formatted(.number.precision(.fractionLength(0))) + temperatureSymbol
            self.date = hourWeather.date
        }
    }
}

//#Preview {
//    HourlyForecastCard()
//}
