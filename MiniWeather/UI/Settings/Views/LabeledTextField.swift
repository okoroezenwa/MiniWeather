//
//  LabeledTextField.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/04/2024.
//

import SwiftUI

struct LabeledTextField: View {
    private let title: String
    private let description: String
    private let prompt: String
    private var text: Binding<String>
    
    init(title: String, description: String, prompt: String, text: Binding<String>) {
        self.title = title
        self.description = description
        self.prompt = prompt
        self.text = text
    }
    
    var body: some View {
        LabeledContent(title) {
            TextField(description, text: text, prompt: Text(prompt))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    Form {
        LabeledTextField(title: "Test", description: "Trying out LabeledTextField preview", prompt: "Hello", text: .constant("Nothing"))
    }
}
