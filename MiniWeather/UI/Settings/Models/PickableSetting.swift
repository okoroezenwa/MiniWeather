//
//  PickableSetting.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 10/05/2024.
//

import Foundation

/// A type of setting where one out of multiple options can be selected.
protocol PickableSetting: DefaultPresenting, CaseIterable, Identifiable, RawRepresentable<String> { }
