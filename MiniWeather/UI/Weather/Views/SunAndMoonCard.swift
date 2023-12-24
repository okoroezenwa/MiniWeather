//
//  SunAndMoonCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct SunAndMoonCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let items: [ArcView.Item]
    @ViewBuilder private let content: () -> Content
    
    init(items: [ArcView.Item], content: @escaping () -> Content) {
        self.items = items
        self.content = content
    }
    
    var body: some View {
        WeatherCard(
            title: "sun & moon",
            showHeader: false
        ) {
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    ForEach(items, id: \.self) { item in
                        ArcView(item: item)
                    }
                }
                .padding(.vertical, 8)
                
                content()
            }
        }
    }
}

struct ArcView: View {
    #warning("Use ProgressView + custom style instead?")
    let item: Item
    let background: some ShapeStyle = .quaternary.opacity(0.15)
    
    var body: some View {
        VStack {
            ZStack {
                arc(start: .degrees(getAngle()), end: .degrees(-180), position: .foreground(item.color))
                
                arc(start: .degrees(0), end: .degrees(180), position: .background)
            }
            .padding(.horizontal, 4)
            
            HStack {
                TimeLabels(time: item.start, day: item.startDay, alignment: .leading)
                
                Spacer()
                
                TimeLabels(time: item.end, day: item.endDay, alignment: .trailing)
            }
        }
        .overlay {
            ZStack {
                image(position: .foreground(item.color))
                
                image(position: .background)
            }
        }
    }
    
    private func image(position: StyleModifier.Position) -> some View {
        Image(systemName: item.symbol)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: 20))
            .modifier(StyleModifier(position: position))
    }
    
    private func arc(start: Angle, end: Angle, position: StyleModifier.Position) -> some View {
        Arc(start: start, end: end)
            .stroke(style: .init(lineWidth: 3, lineCap: .round))
            .aspectRatio(2, contentMode: .fit)
            .modifier(StyleModifier(position: position))
    }
    
    private func getAngle() -> Double {
        let start = item.progress * 180
        return -(180 - start)
    }
    
    struct TimeLabels: View {
        let time: String
        let day: String
        let alignment: HorizontalAlignment
        
        var body: some View {
            VStack(alignment: alignment, spacing: 2) {
                Text(time)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                
                Text(day)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
        }
    }
    
    struct Item: Hashable {
        let progress: Double
        let start: String
        let end: String
        let color: Color
        let symbol: String
        let startDay: String
        let endDay: String
    }
    
    struct StyleModifier: ViewModifier {
        enum Position {
            case foreground(Color)
            case background
        }
        
        let position: Position
        
        func body(content: Content) -> some View {
            switch position {
                case .foreground(let color):
                    content
                        .foregroundStyle(color)
                case .background:
                    content
                        .foregroundStyle(.quaternary.opacity(0.15))
            }
        }
    }
    
    struct ArcModifier: ViewModifier {
        let position: StyleModifier.Position
        
        func body(content: Content) -> some View {
            content
                .aspectRatio(2, contentMode: .fit)
                .modifier(StyleModifier(position: position))
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

#Preview {
    SunAndMoonCard(
        items: [.init(progress: 0.5, start: "06:53", end: "18:12", color: .yellow, symbol: "sun.max.fill", startDay: "Today", endDay: "Tomorrow")],
        content: {
            EmptyView()
        }
    )
    .background {
        Image(.lightBackground)
    }
}
