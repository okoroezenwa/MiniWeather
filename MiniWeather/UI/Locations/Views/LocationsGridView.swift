//
//  LocationsGridView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct LocationsGridView<Current: View, Saved: View>: View {
    private let hasLocations: Bool
    @State private var isShowingSettings = false
    @ViewBuilder private let currentLocationSection: () -> Current
    @ViewBuilder private let savedLocationsSection: () -> Saved
    
    init(hasLocations: Bool, currentLocationSection: @escaping () -> Current, savedLocationsSection: @escaping () -> Saved) {
        self.hasLocations = hasLocations
        self.currentLocationSection = currentLocationSection
        self.savedLocationsSection = savedLocationsSection
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(
                alignment: .leading,
                spacing: 12
            ) {
                currentLocationSection()
                
                if hasLocations {
                    savedLocationsSection()
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Locations")
        .toolbarBackground(.thinMaterial, for: .automatic)
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            
            
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        #endif
        .sheet(isPresented: $isShowingSettings) {
            SettingsView() {
                isShowingSettings = false
            }
        }
    }
}

#Preview {
    LocationsGridView(hasLocations: true) {
        EmptyView()
    } savedLocationsSection: {
        EmptyView()
    }
}
