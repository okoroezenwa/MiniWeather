//
//  FilledSwipeActionStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/04/2024.
//

import SwiftUI

struct FilledSwipeActionStyle: SwipeActionStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            Task { @MainActor in
                configuration.action()
            }
        } label: {
            Rectangle()
                .overlay(alignment: .leading) {
                    configuration.label
                        .font(configuration.font)
                        .foregroundStyle(configuration.foregroundStyle)
                        .frame(width: configuration.widths.label)
                }
                .foregroundStyle(.clear)
                .background(configuration.swipeAction.tint)
                .frame(width: configuration.widths.container)
                .frame(maxHeight: .infinity)
                .clipped()
        }
        .buttonStyle(.plain)
    }
}

extension SwipeActionStyle where Self == FilledSwipeActionStyle {
    static var filled: FilledSwipeActionStyle {
        FilledSwipeActionStyle()
    }
}
