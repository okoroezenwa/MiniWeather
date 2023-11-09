//
//  Listener.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/11/2023.
//

import Foundation

protocol Broadcaster<Property> {
    associatedtype Property
    
    func getState() -> Property
    func register(_ observer: any Listener)
    func unregister(_ observer: any Listener)
    func notifyObservers()
}

protocol Listener {
    var id: UUID { get }
    func update()
}
