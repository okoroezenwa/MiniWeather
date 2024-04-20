//
//  Collection+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/04/2024.
//

import Foundation

extension Collection {
    func value(if condition: Bool) -> Self? {
        guard condition else {
            return nil
        }
        return self
    }
}
