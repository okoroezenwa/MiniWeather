//
//  DailyForecastCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct DailyForecastCard: View {
    let timeZone: TimeZone?
    let temperatureUnit: UnitTemperature
    let collection: Forecast<DayWeather>
    
    var body: some View {
        WeatherCard(title: "10-Day Forecast", showHeader: false) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Color.clear
                        .frame(width: 8)
                    
                    ForEach(collection, id: \.date) { forecast in
                        let isToday = collection.first == forecast
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.primary.opacity(0.1))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 0) {
                                    ZStack(alignment: .leading) {
                                        Text("Today")
                                            .opacity(isToday ? 1 : 0)
                                        
                                        Text(forecast.date.in(timeZone: timeZone).formatted(.dateTime.weekday(.abbreviated)))
                                            .opacity(isToday ? 0 : 1)
                                    }
                                    
                                    Spacer(minLength: 8)
                                    
                                    Image(unfilledSymbol: forecast.symbolName)
                                        .symbolRenderingMode(.hierarchical)
                                }
                                
                                RoundedRectangle(cornerRadius: 0.75)
                                    .frame(height: 1.5)
                                    .frame(maxWidth: 16)
                                    .foregroundStyle(.tertiary)
                                
                                HStack(spacing: 0) {
                                    TemperatureLimitView(header: "thermometer.low", value: forecast.lowTemperature.converted(to: temperatureUnit).value.formatted(.number.precision(.fractionLength(0))))
                                    
                                    Spacer(minLength: 8)
                                    
                                    TemperatureLimitView(header: "thermometer.high", value: forecast.highTemperature.converted(to: temperatureUnit).value.formatted(.number.precision(.fractionLength(0))))
                                }
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
    
    private struct TemperatureLimitView: View {
        let header: String
        let value: String
        
        var body: some View {
            HStack(spacing: 2) {
                Image(unfilledSymbol: header)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
                
                Text(value)
            }
        }
    }
}

//#Preview {
//    DailyForecastCard()
//}
