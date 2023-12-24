//
//  PrecipitationCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct PrecipitationCard: View {
    private let value: Double?
    private let unit: UnitLength
    private let items: [[WeatherCardGridViewItem.Model]]
    
    init(value: Double?, unit: UnitLength, items: [[WeatherCardGridViewItem.Model]]) {
        self.value = value
        self.unit = unit
        self.items = items
    }
    
    var body: some View {
        WeatherCard(
            title: "precipitation",
            imageName: "drop.fill",
            value: value?.formatted(.number.precision(.fractionLength(0))) ?? "--",
            unit: unit.symbol
        ) {
            WeatherCardGridView(
                items: items
            )
        }
    }
}

//#Preview {
//    PrecipitationCard()
//}
