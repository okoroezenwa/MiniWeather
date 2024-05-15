//
//  SettingsLink.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/04/2024.
//

import SwiftUI

struct SettingsLink: View {
    private let name: String
    private let imageName: String
    private let urlString: String
    
    init(name: String, imageName: String = "arrow.up.right", urlString: String) {
        self.name = name
        self.imageName = imageName
        self.urlString = urlString
    }
    
    var body: some View {
        Link(destination: .init(string: urlString)!) {
            HStack() {
                Text(name)
                
                Spacer()
                
                Image(systemName: imageName)
            }
        }
    }
}

#Preview {
    Form {
        SettingsLink(name: "Test", urlString: "https://www.apple.com")
    }
}
