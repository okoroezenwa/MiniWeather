//
//  Image+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 15/12/2023.
//

import SwiftUI

extension Image {
    init(unfilledSymbol: String) {
        if let _ = UIImage(systemName: unfilledSymbol + ".fill") {
            self = Image(systemName: unfilledSymbol + ".fill")
        } else {
            self = Image(systemName: unfilledSymbol)
        }
    }
}
