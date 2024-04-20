//
//  MaterialView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct MaterialView<Content: View, SomeMaterial: ShapeStyle>: View {
    @Environment(\.colorScheme) var colorScheme
    private let insets: Insets
    private let spacing: CGFloat
    private let content: Content
    private let info: (material: SomeMaterial, opacity: CGFloat)
    
    init(
        info: (material: SomeMaterial, opacity: CGFloat) = (.thinMaterial, 1),
        spacing: CGFloat = 10,
        insets: Insets = .init(),
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
        self.info = info
        self.insets = insets
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .padding(insets.edgeInsets)
        .background(info.material.opacity(info.opacity))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

#Preview {
    MaterialView<LocationCell, Material>(insets: .init(value: 16)) {
        LocationCell(
            location: UniversalConstants.location,
            weather: UniversalConstants.weather,
            isCurrentLocation: true,
            shouldDisplayAsLoading: false
        )
    }
}

extension MaterialView {
    struct Insets {
        let top: CGFloat
        let bottom: CGFloat
        let leading: CGFloat
        let trailing: CGFloat
        
        var edgeInsets: EdgeInsets {
            .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
        }
        
        init(top: CGFloat = 16, bottom: CGFloat = 16, leading: CGFloat = 16, trailing: CGFloat = 16) {
            self.top = top
            self.bottom = bottom
            self.leading = leading
            self.trailing = trailing
        }
        
        init(value: CGFloat) {
            self.top = value
            self.bottom = value
            self.leading = value
            self.trailing = value
        }
    }
}
