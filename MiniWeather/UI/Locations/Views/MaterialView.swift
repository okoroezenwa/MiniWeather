//
//  MaterialView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct MaterialView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    private let leadingPadding: CGFloat
    private let trailingPadding: CGFloat
    private let spacing: CGFloat
    private let content: Content
    
    init(spacing: CGFloat = 10, topPadding: CGFloat = 16, bottomPadding: CGFloat = 16, leadingPadding: CGFloat = 16, trailingPadding: CGFloat = 16,  @ViewBuilder content: () -> Content) {
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .padding(.top, topPadding)
        .padding(.leading, leadingPadding)
        .padding(.bottom, bottomPadding)
        .padding(.trailing, trailingPadding)
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

#Preview {
    MaterialView(bottomPadding: 16) {
        LocationCell(
            location: UniversalConstants.location,
            weather: UniversalConstants.weather,
            isCurrentLocation: true,
            shouldDisplayAsLoading: false
        )
    }
}
