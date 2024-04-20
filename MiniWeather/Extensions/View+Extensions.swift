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
    
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
    
    func onDrag<V: View>(if enabled: Bool, _ data: @escaping () -> NSItemProvider, @ViewBuilder preview: @escaping () -> V) -> some View {
        self.modifier(Draggable(condition: enabled, data: data, preview: preview))
    }
    
    func swipeActionStyle<S: SwipeActionStyle>(_ style: S) -> some View {
        environment(\.swipeActionStyle, AnySwipeActionStyle(style: style))
    }
}

