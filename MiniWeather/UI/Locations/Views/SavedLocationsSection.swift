//
//  SavedLocationsSection.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct SavedLocationsSectionViewModel {
    let locations: [Location]
    let weather: (Location) -> Binding<WeatherProtocol?>
    let onDelete: (Location) -> Void
}

struct SavedLocationsSection: View {
    private let viewModel: SavedLocationsSectionViewModel
    
    init(viewModel: SavedLocationsSectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ForEach(viewModel.locations) { location in
            NavigationLink(value: location) {
                MaterialView(bottomPadding: 12) {
                    LocationCell(
                        location: location,
                        weather: viewModel.weather(location).wrappedValue,
                        isCurrentLocation: false,
                        shouldDisplayAsLoading: false
                    )
                }
                #if os(iOS)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
                #endif
                .contextMenu {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.onDelete(location)
                        }
                    } label: {
                        Label("Delete Location", systemImage: "trash")
                    }
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .leading))
        }
        .animation(.easeInOut, value: viewModel.locations)
    }
}

#Preview {
    SavedLocationsSection(viewModel: .init(locations: [UniversalConstants.location], weather: { _ in Binding(get: { UniversalConstants.weather }, set: { _ in }) }, onDelete: { _ in }))
}
