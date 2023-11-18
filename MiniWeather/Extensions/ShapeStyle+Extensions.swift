//
//  ShapeStyle+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    static func cellBackgroundColour(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .light {
            return .white.opacity(0.3)
        } else {
            return .black.opacity(0.3)
        }
    }
}
