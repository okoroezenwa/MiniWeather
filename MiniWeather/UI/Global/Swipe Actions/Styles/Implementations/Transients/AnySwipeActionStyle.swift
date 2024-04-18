//
//  AnySwipeActionStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/04/2024.
//

import SwiftUI

struct AnySwipeActionStyle: SwipeActionStyle {
    private var _makeBody: (Configuration) -> AnyView
    
    init<S: SwipeActionStyle>(style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}
