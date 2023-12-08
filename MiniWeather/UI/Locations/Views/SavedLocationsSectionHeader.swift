//
//  SavedLocationsSectionHeader.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct SavedLocationsSectionHeader: View {
    var body: some View {
        Text("Saved Locations")
            .font(
                .system(size: 20, weight: .semibold)
            )
            .padding([.horizontal, .top], 16)
    }
}

#Preview {
    SavedLocationsSectionHeader()
}
