//
//  CurrentLocationSectionHeader.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct CurrentLocationSectionHeader: View {
    private let shouldShowProgressView: Bool
    
    init(shouldShowProgressView: Bool) {
        self.shouldShowProgressView = shouldShowProgressView
    }
    
    var body: some View {
        HStack {
            Text("Current Location")
                .font(
                    .system(size: 20, weight: .semibold)
                )
            
            Spacer()
            
            if shouldShowProgressView {
                ProgressView()
            }
        }
        .padding([.top, .horizontal], 16)
    }
}

#Preview {
    CurrentLocationSectionHeader(shouldShowProgressView: true)
}
