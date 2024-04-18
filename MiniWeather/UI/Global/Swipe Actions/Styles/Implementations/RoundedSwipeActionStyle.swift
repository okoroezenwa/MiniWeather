//
//  RoundedSwipeActionStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/04/2024.
//

import SwiftUI

struct RoundedSwipeActionStyle: SwipeActionStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            Task { @MainActor in
                configuration.action()
            }
        } label: {
            Rectangle()
                .overlay(alignment: .leading) {
                    Circle()
                        .fill(configuration.swipeAction.tint)
                        .overlay {
                            configuration.label
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        .frame(square: configuration.widths.label - 16)
                        .padding(.leading, 16)
                        .visualEffect { content, proxy in
                            content
                                .opacity(configuration.visualEffects.opacity)
                                .scaleEffect(configuration.visualEffects.scale)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 5)
                }
                .foregroundStyle(.clear)
                .frame(width: configuration.widths.container)
                .frame(maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
}

extension SwipeActionStyle where Self == RoundedSwipeActionStyle {
    static var rounded: RoundedSwipeActionStyle {
        RoundedSwipeActionStyle()
    }
}
