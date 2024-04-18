//
//  DefaultSwipeActionStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/04/2024.
//

import SwiftUI

struct DefaultSwipeActionStyle: SwipeActionStyle {
    func makeBody(configuration: Configuration) -> some View {
        RoundedSwipeActionStyle()
            .makeBody(configuration: configuration)
    }
}
