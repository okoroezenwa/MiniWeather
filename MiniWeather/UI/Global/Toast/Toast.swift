//
//  Toast.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/04/2024.
//

import SwiftUI

struct Toast: Equatable {
    enum Style: Equatable {
        case error
        case warning
        case success
        case info
        case delete
        case custom(color: Color, icon: String)
    }
    
    var style: Style
    var title: String
    var message: AttributedString
    var duration: Double = 7
    var trailingButton: TrailingButton?
    var onDismiss: (() -> Void)?
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.style == rhs.style && lhs.title == rhs.title && lhs.message == rhs.message
    }
}

extension Toast {
    struct TrailingButton {
        enum Style {
            case text(String)
            case image(String)
        }
        
        let style: Style
        let action: (() -> Void)
    }
}

extension Toast.Style {
    var themeColor: Color {
        switch self {
            case .error, .delete:
                return .red
            case .warning:
                return .orange
            case .info:
                return .blue
            case .success:
                return .green
            case .custom(color: let color, icon: _):
                return color
        }
    }
    
    var icon: String {
        switch self {
            case .info:
                return "info.circle.fill"
            case .warning:
                return "exclamationmark.circle.fill"
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "xmark.circle.fill"
            case .delete:
                return "trash.circle.fill"
            case .custom(color: _, icon: let icon):
                return icon
        }
    }
    
    var feedback: SensoryFeedback {
        switch self {
            case .info:
                return .impact
            case .warning:
                return .warning
            case .success:
                return .success
            case .error:
                return .error
            case .delete:
                return .decrease
            case .custom:
                return .impact(weight: .light)
        }
    }
}
