//
//  Calendar+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 15/12/2023.
//

import Foundation

extension Calendar {
    static func withTimeZone(_ timeZone: TimeZone) -> Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = timeZone
        return calendar
    }
}
