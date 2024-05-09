//
//  Loggable.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/05/2024.
//

import OSLog

protocol Loggable { }

extension Loggable {
    var logger: Logger { Logger(subsystem: "com.okoroezenwa.MiniWeather", category: String(describing: Self.self)) }
}
