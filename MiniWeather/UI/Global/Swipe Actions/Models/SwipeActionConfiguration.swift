//
//  SwipeActionConfiguration.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/04/2024.
//

import SwiftUI

struct SwipeActionConfiguration {
    let swipeAction: SwipeAction
    let widths: Widths
    let font: Font = .title
    let foregroundStyle: Color = .white
    let visualEffects: VisualEffects
    let colorScheme: ColorScheme
    let action: @MainActor () -> Void
    let label: Label
}

// Label Definition
extension SwipeActionConfiguration {
    struct Label: View {
        init<Content: View>(content: Content) {
            body = AnyView(content)
        }
        
        var body: AnyView
    }
}

extension SwipeActionConfiguration {
    struct Widths {
        let label: CGFloat
        let container: CGFloat
    }
    
    struct VisualEffects {
        let opacity: CGFloat
        let scale: CGSize
    }
}
