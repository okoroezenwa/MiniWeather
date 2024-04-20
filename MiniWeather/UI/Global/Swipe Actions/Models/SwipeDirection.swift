//
//  SwipeDirection.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/04/2024.
//

import SwiftUI

enum SwipeDirection {
    case leading, trailing
    
    var alignment: Alignment {
        switch self {
            case .leading:
                return .leading
            case .trailing:
                return .trailing
        }
    }
}
