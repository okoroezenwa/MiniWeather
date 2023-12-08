//
//  SectionContainerView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI
import CoreLocation

struct SectionContainerView<Content: View, Header: View>: View {
    @ViewBuilder private var content: () -> Content
    @ViewBuilder private var header: () -> Header
    
    init(content: @escaping () -> Content, header: @escaping () -> Header) {
        self.content = content
        self.header = header
    }
    
    var body: some View {
        Section {
            content()
        } header: {
            header()
        }
    }
}

#Preview {
    SectionContainerView() {
        EmptyView()
    } header: {
        EmptyView()
    }
}
