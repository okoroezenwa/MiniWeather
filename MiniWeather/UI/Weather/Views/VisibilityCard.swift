//
//  VisibilityCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct VisibilityCard: View {
    private let value: Measurement<UnitLength>
    private let visibility: WeatherVisibility
    private let unit: UnitLength
    
    init(value: Measurement<UnitLength>, visibility: WeatherVisibility, unit: UnitLength) {
        self.value = value
        self.visibility = visibility
        self.unit = unit
    }
    
    var body: some View {
        WeatherCard(
            title: "visibility",
            imageName: "eye.fill",
            value: value.converted(to: unit).value.formatted(.number.precision(.fractionLength(1))),
            unit: unit.symbol
        ) {
            WeatherCardTitleSubtitleView(
                title: visibility.rawValue,
                subtitle: visibility.subtitle()
            )
        }
    }
}

extension VisibilityCard {
    enum WeatherVisibility: String {
        case extremelyLow = "Extremely Low"
        case veryLow = "Very Low"
        case low = "Low"
        case average = "Average"
        case good = "Good"
        case excellent = "Excellent"
        
        static func visibility(from value: Double) -> Self {
            switch value {
                case let x where x < 100:
                    return .extremelyLow
                case let x where (100..<1000).contains(x):
                    return .veryLow
                case let x where (1000..<2000).contains(x):
                    return .low
                case let x where (2000..<5000).contains(x):
                    return .average
                case let x where (5000..<8000).contains(x):
                    return .good
                case let x where x >= 8000:
                    return .excellent
                default: return .average
            }
        }
        
        func subtitle() -> String {
            switch self {
                case .extremelyLow, .veryLow:
                    return "It is best to stay indoors."
                case .low:
                    return "Take caution when venturing out."
                case .average:
                    return "Moderate risk from moving vehicles."
                case .good, .excellent:
                    return "Conditions are good to go!"
            }
        }
    }
}

//#Preview {
//    VisibilityCard()
//}
