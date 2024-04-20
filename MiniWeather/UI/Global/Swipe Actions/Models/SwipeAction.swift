//
//  SwipeAction.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/04/2024.
//

import SwiftUI

struct SwipeAction: Identifiable, Equatable {
    let id = UUID()
    let tint: Color
    let name: String
    let icon: String
    let isEnabled: Bool
    let shouldResetPosition: Bool
    let action: @MainActor () -> Void
    
    init(tint: Color, name: String, icon: String, isEnabled: Bool = true, shouldResetPosition: Bool = true, action: @escaping () -> Void) {
        self.tint = tint
        self.name = name
        self.icon = icon
        self.isEnabled = isEnabled
        self.shouldResetPosition = shouldResetPosition
        self.action = action
    }
    
    static func == (lhs: SwipeAction, rhs: SwipeAction) -> Bool {
        return lhs.id == rhs.id
    }
}
