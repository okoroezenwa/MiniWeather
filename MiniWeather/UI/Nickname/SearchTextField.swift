//
//  SearchTextField.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 20/04/2024.
//

import SwiftUI

struct SearchTextField: View {
    @Binding var text: String
    
    let placeholder: String
    let canShowClearButton: Bool
    
    init(placeholder: String, text: Binding<String>, canShowClearButton: Bool = true) {
        self._text = text
        self.placeholder = placeholder
        self.canShowClearButton = canShowClearButton
    }
    
    var body: some View {
        HStack(spacing: 0) {
            TextField(placeholder, text: $text)
                .padding([.vertical, .leading], 8)
                .padding(.trailing, canShowClearButton && !text.isEmpty ? 0 : 8)
            
            if canShowClearButton && !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(square: 22)
                .padding(.trailing, 4)
            }
        }
        .background(.primary.opacity(0.05))
        .clipShape(.rect(cornerRadius: 10))
    }
}

extension SearchTextField {
    struct EditInfo {
        let purpose: String
        let placeholder: String
        var text: String
    }
}
