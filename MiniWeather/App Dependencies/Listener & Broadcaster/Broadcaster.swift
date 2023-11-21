//
//  Broadcaster.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import Foundation

/// An object that can notify its observers of changes to its Property object.
protocol Broadcaster<Property> {
    associatedtype Property
    
    func getState() -> Property
    func register(_ observer: any Listener)
    func unregister(_ observer: any Listener)
    func notifyObservers()
}
