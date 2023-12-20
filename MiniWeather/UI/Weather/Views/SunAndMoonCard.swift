//
//  SunAndMoonCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct SunAndMoonCard: View {
    private let weather: Weather
    
    init(weather: Weather) {
        self.weather = weather
    }
    
    var body: some View {
        WeatherCard(
            title: "sun & moon",
            showHeader: false
        ) {
            HStack {
                Arc(start: .degrees(0), end: .degrees(180))
                    .stroke(style: .init(lineWidth: 3, lineCap: .round))
                    .foregroundStyle(.yellow)
                    .aspectRatio(2, contentMode: .fit)
                
                Arc(start: .degrees(0), end: .degrees(180))
                    .stroke(style: .init(lineWidth: 3, lineCap: .round))
                    .foregroundStyle(.tertiary)
                    .aspectRatio(2, contentMode: .fit)
            }
        }
    }
}

struct Arc: Shape {
    let start: Angle
    let end: Angle
    
    func path(in rect: CGRect) -> Path {
        let r = rect.height / 2 * 2
        let center = CGPoint(x: rect.midX, y: rect.midY * 2)
        var path = Path()
        path.addArc(
            center: center, 
            radius: r,
            startAngle: start,
            endAngle: end,
            clockwise: true
        )
        return path
    }
}

//#Preview {
//    SunAndMoonCard()
//}
