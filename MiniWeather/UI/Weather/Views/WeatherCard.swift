//
//  WeatherCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI

struct WeatherCard<Content: View, Trailing: View>: View {
    private var spacing: CGFloat
    private let title: String
    private let imageName: String
    private let value: String
    private let unit: String
    private let showHeader: Bool
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let trailingHeaderView: () -> Trailing
    
    init(
        spacing: CGFloat = 12,
        title: String,
        imageName: String,
        value: String,
        unit: String,
        showHeader: Bool = true,
        content: @escaping () -> Content,
        trailingHeaderView: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.spacing = spacing
        self.title = title
        self.imageName = imageName
        self.value = value
        self.unit = unit
        self.showHeader = showHeader
        self.content = content
        self.trailingHeaderView = trailingHeaderView
    }
    
    init(spacing: CGFloat = 12,
         title: String,
         showHeader: Bool = true,
         content: @escaping () -> Content,
         trailingHeaderView: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.spacing = spacing
        self.title = title
        self.imageName = ""
        self.value = ""
        self.unit = ""
        self.showHeader = showHeader
        self.content = content
        self.trailingHeaderView = trailingHeaderView
    }
    
    var body: some View {
        MaterialView(spacing: spacing) {
            HStack {
                WeatherCardTrailingHeaderTextView(text: title)
                
                Spacer()
                
                trailingHeaderView()
            }
            
            if showHeader {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.primary.opacity(0.1))
                            .frame(square: 50)
                        
                        Image(unfilledSymbol: imageName)
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 24))
                    }
                    
                    HStack(
                        alignment: .firstTextBaseline,
                        spacing: 2) {
                            Text(value)
                                .font(.system(size: 45, weight: .regular, design: .rounded))
                            
                            Text(unit)
                                .font(.system(size: 25, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    
                    Spacer()
                }
            }
            
            content()
        }
    }
}

//#Preview {
//    WeatherCard()
//}
