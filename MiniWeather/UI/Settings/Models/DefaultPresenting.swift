//
//  DefaultPresenting.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 10/05/2024.
//

import Foundation

/// An object that has a default value to start with.
protocol DefaultPresenting {
    static var `default`: Self { get }
}
