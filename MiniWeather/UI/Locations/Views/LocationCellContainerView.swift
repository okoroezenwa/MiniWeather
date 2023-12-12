//
//  LocationCellContainerView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct LocationCellContainerView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    private let topPading: CGFloat = 16
    private let bottomPadding: CGFloat
    private let leadingPadding: CGFloat = 16
    private let trailingPadding: CGFloat = 16
    private let content: Content
    
    init(bottomPadding: CGFloat, @ViewBuilder content: () -> Content) {
        self.bottomPadding = bottomPadding
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 10) {
            content
        }
        .padding(.top, topPading)
        .padding(.leading, leadingPadding)
        .padding(.bottom, bottomPadding)
        .padding(.trailing, trailingPadding)
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

#Preview {
    LocationCellContainerView(bottomPadding: 16) {
        LocationCell(
            location: UniversalConstants.location,
            weather: UniversalConstants.weather,
            isCurrentLocation: true,
            shouldDisplayAsLoading: false
        )
    }
}
