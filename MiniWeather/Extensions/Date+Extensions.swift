//
//  Date+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/12/2023.
//

import Foundation

extension Date {
    /**
     Converts from the origin time zone to the detination time zone.
     
     The destination time zone will probably be the current time zone.
     
     - parameters:
        - timeZone: The time zone for the date object.
        - destinationTimeZone: The time zone to be converted to.
     */
    func convert(from timeZone: TimeZone, to destinationTimeZone: TimeZone) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents(in: timeZone, from: self)
        components.timeZone = destinationTimeZone
        return calendar.date(from: components)!
    }
}

