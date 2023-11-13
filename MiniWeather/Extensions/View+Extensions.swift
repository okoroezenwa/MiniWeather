//
//  View+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 10/11/2023.
//

import SwiftUI

extension View {
    public func frame(square: CGFloat, alignment: Alignment = .center) -> some View {
        frame(width: square, height: square, alignment: alignment)
    }
}
