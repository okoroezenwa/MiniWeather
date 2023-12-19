//
//  WeatherCardChildren.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI

struct WeatherCardGridView: View {
    private let items: [[Item]]
    
    init(items: [[Item]]) {
        self.items = items
    }
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            ForEach(items, id: \.self) { subItems in
                GridRow {
                    ForEach(subItems) { item in
                        WeatherCardGridViewItem(item: item)
                    }
                }
            }
        }
    }
    
    struct Item: Hashable, Identifiable {
        let imageName: String
        let value: String
        let header: String
        let angle: Double
        let id = UUID()
        
        init(imageName: String, value: String, header: String, angle: Double = 0) {
            self.imageName = imageName
            self.value = value
            self.header = header
            self.angle = angle
        }
    }
}

struct WeatherCardTitleSubtitleView: View {
    private let title: String
    private let subtitle: String
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(subtitle)
                    .font(
                        .system(size: 15)
                    )
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct WeatherCardGridViewItem: View {
    private let item: WeatherCardGridView.Item
    
    init(item: WeatherCardGridView.Item) {
        self.item = item
    }
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.primary.opacity(0.1))
                    .frame(square: 35)
                
                Image(systemName: item.imageName)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 18))
                    .visualEffect { content, _ in
                        content
                            .rotationEffect(.degrees(item.angle))
                    }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.header)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                Text(item.value)
                    .font(.system(size: 15, weight: .semibold))
            }
            
            Spacer()
        }
    }
}

struct WeatherCardTrailingHeaderTextView: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 16, weight: .heavy, design: .rounded))
    }
}
