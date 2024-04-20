//
//  ImageBackgroundView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 20/04/2024.
//

import SwiftUI

struct ImageBackgroundView<Content: View>: View {
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Image(colorScheme == .light ? .lightBackground : .darkBackground)
                .resizable()
                .ignoresSafeArea(.all)
            
            content
        }
    }
}
