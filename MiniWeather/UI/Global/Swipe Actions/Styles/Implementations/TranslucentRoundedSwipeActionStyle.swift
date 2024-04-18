//
//  TranslucentRoundedSwipeActionStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/04/2024.
//

import SwiftUI

struct TranslucentRoundedSwipeActionStyle: SwipeActionStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            Task { @MainActor in
                configuration.action()
            }
        } label: {
            Rectangle()
                .overlay(alignment: .leading) {
                    Circle()
                        .fill(.thinMaterial)
                        .background {
                            configuration.swipeAction.tint
                                .frame(square: 20)
                                .blur(radius: 10)
                        }
                        .overlay {
                            configuration.label
                                .font(.title2)
                                .foregroundStyle(getForegroundColour(using: configuration))
                        }
                        .frame(square: configuration.widths.label - 16)
                        .padding(.leading, 16)
                        .visualEffect { content, proxy in
                            content
                                .opacity(configuration.visualEffects.opacity)
                                .scaleEffect(configuration.visualEffects.scale)
                        }
                        .shadow(color: configuration.swipeAction.tint.opacity(0.1), radius: 5)
                }
                .foregroundStyle(.clear)
                .frame(width: configuration.widths.container)
                .frame(maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    func getForegroundColour(using configuration: Configuration) -> Color {
        configuration.colorScheme == .dark ? .white : .black
    }
}

extension SwipeActionStyle where Self == TranslucentRoundedSwipeActionStyle {
    static var translucentRounded: TranslucentRoundedSwipeActionStyle {
        TranslucentRoundedSwipeActionStyle()
    }
}
