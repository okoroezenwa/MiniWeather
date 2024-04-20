//
//  FullBorderedButtonStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 20/04/2024.
//

import SwiftUI

struct FullBorderedButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .background(colorScheme == .light ? .black : .white)
            .clipShape(.rect(cornerRadius: 16))
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == FullBorderedButtonStyle {
    static var fullBordered: FullBorderedButtonStyle { FullBorderedButtonStyle() }
}
