//
//  WindAndPressureCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct WindAndPressureCard: View {
    private let value: Double
    private let unit: UnitSpeed
    private let items: [[WeatherCardGridViewItem.Model]]
    
    init(value: Double, unit: UnitSpeed, items: [[WeatherCardGridViewItem.Model]]) {
        self.value = value
        self.unit = unit
        self.items = items
    }
    
    var body: some View {
        WeatherCard(
            title: "wind & pressure",
            imageName: "fan.fill",
            value: value.formatted(.number.precision(.fractionLength(1))),
            unit: unit.symbol
        ) {
            WeatherCardGridView(
                items: items
            )
        }
    }
}

//#Preview {
//    WindAndPressureCard()
//}
