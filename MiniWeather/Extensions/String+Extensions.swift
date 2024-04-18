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
    
    func grantAttributes(to string: String, values: [AttributedString.AttributeValue]) -> AttributedString {
        var attributed = AttributedString(self)
        
        guard let range = attributed.range(of: string) else {
            return attributed
        }
        
        for value in values {
            switch value {
                case .font(let font):
                    attributed[range].font = font
                case .foreground(let colour):
                    attributed[range].foregroundColor = colour
            }
        }
        
        return attributed
    }
    
    func grantAttributes(to string: String, values: AttributedString.AttributeValue...) -> AttributedString {
        grantAttributes(to: string, values: values)
    }
}
