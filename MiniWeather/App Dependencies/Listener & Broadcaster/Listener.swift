//
//  Listener.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import Foundation

/// An object that listens for any changes to the Broadcaster's property state.
protocol Listener {
    var id: UUID { get }
    func update()
}
