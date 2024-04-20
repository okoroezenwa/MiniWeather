//
//  SwipeActionButton.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/04/2024.
//

import SwiftUI

struct SwipeActionButton<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.swipeActionStyle) var swipeActionStyle
    let swipeAction: SwipeAction
    let widths: SwipeActionConfiguration.Widths
    let visualEffects: SwipeActionConfiguration.VisualEffects
    let action: @MainActor () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        swipeActionStyle
            .makeBody(
                configuration: SwipeActionConfiguration(
                    swipeAction: swipeAction,
                    widths: widths,
                    visualEffects: visualEffects,
                    colorScheme: colorScheme,
                    action: action,
                    label: SwipeActionConfiguration.Label(
                        content: content
                    )
                )
            )
    }
}
