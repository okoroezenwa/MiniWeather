//
//  Date+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/12/2023.
//

import Foundation

extension Date {
    /**
     Converts the current date to the date in the given time zone.
     
     - parameter timeZone: The time zone for the date to be converted to.
     - Returns: The current date in the given time zone.
     */
    func `in`(timeZone: TimeZone?) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents(in: timeZone ?? .autoupdatingCurrent, from: self)
        components.timeZone = .autoupdatingCurrent
        return calendar.date(from: components) ?? .now
    }
}

