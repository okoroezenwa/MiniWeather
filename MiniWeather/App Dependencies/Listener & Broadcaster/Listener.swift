//
//  Listener.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import Foundation

protocol Listener {
    var id: UUID { get }
    func update()
}
