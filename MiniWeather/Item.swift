//
//  Item.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
