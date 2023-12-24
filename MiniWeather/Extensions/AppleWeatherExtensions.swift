//
//  AppleWeatherExtensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 20/12/2023.
//

import Foundation
import WeatherKit

extension Weather {
    func today() -> DayWeather? {
        dailyForecast.first(where: { Calendar.autoupdatingCurrent.isDateInToday($0.date) })
    }
    
    func tomorrow() -> DayWeather? {
        dailyForecast.first(where: { Calendar.autoupdatingCurrent.isDateInTomorrow($0.date) })
    }
}
