//
//  String+Extensions.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 14/12/2023.
//

import Foundation

extension String {
    var sentenceCased: String {
        prefix(1).capitalized + dropFirst()
    }
}
