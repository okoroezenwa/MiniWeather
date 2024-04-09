//
//  Toast.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/04/2024.
//

import SwiftUI

struct Toast {
    enum Style {
        case error
        case warning
        case success
        case info
        case delete
        case custom(color: Color, icon: String)
    }
    
    var style: Style
    var title: String
    var message: String
    var trailingButton: TrailingButton?
    var duration: Double = 7
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
                return "exclamationmark.triangle.fill"
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
}
