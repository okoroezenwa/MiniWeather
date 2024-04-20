//
//  SwipeActionStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/04/2024.
//

import SwiftUI

protocol SwipeActionStyle {
    associatedtype Body: View
    typealias Configuration = SwipeActionConfiguration
    
    func makeBody(configuration: Configuration) -> Body
}



#warning("Organise later?")



struct SwipeActionStyleKey: EnvironmentKey {
    static var defaultValue = AnySwipeActionStyle(style: DefaultSwipeActionStyle())
}

extension EnvironmentValues {
    var swipeActionStyle: AnySwipeActionStyle {
        get { self[SwipeActionStyleKey.self] }
        set { self[SwipeActionStyleKey.self] = newValue }
    }
}
