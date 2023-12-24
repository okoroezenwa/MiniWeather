//
//  WeatherCardChildren.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI

struct WeatherCardGridView: View {
    private let items: [[WeatherCardGridViewItem.Model]]
    
    init(items: [[WeatherCardGridViewItem.Model]]) {
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
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct WeatherCardGridViewItem: View {
    private let item: Model
    
    init(item: Model) {
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
                    .foregroundStyle(.secondary)
                
                Text(item.value)
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            
            Spacer()
        }
    }
    
    struct Model: Hashable, Identifiable {
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

struct WeatherCardTrailingHeaderTextView: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 16, weight: .heavy, design: .rounded))
    }
}
