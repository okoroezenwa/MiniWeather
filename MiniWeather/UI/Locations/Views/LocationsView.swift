//
//  LocationsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import SwiftUI
import SwiftData

struct LocationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var locations: [Location]
    @State private var isAddLocationViewVisible = false
    @State var addedLocations = [(location: Location, weather: Weather)]()
    @State var selectedLocation: Location?
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationSplitView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 12) {
                    if let location = viewModel.currentLocation {
                        Section {
                            locationCell(for: location, isCurrentLocation: true)
                        } header: {
                            Text("Current Location")
                                .font(
                                    .system(size: 20, weight: .semibold)
                                )
                        }
                    }
                    
                    if !locations.isEmpty {
                        Section {
                            ForEach(locations) { location in
                                NavigationLink(value: location) {
                                    locationCell(for: location, isCurrentLocation: false)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Text("Saved Locations")
                                .font(
                                    .system(size: 20, weight: .semibold)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .background {
                background(for: colorScheme)
            }
            .navigationTitle("Locations")
            .navigationDestination(for: Location.self) { location in
                LocationDetailView(location: location)
            }
            .toolbarBackground(.thinMaterial, for: .automatic)
            .toolbar {
                Button {
                    isAddLocationViewVisible.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .overlay {
                if locations.isEmpty {
                    ContentUnavailableView(
                        "No Cities Added",
                        systemImage: "line.horizontal.3.circle",
                        description: Text("Searched cities you add will appear here.")
                    )
                }
            }
        } detail: {
            detailContentUnavailableView()
                .background {
                    background(for: colorScheme)
                }
                .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $isAddLocationViewVisible) {
            addLocationView()
        }
    }
    
    private func delete(_ location: Location) {
        withAnimation {
            modelContext.delete(location)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(locations[index])
            }
        }
    }
    
    // MARK: - Local Views
    private func locationCell(for location: Location, isCurrentLocation: Bool) -> some View {
        LocationCell(
            location: location,
            weather: addedLocations.first { $0.location == location }?.weather, 
            isCurrentLocation: isCurrentLocation
        )
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            if !isCurrentLocation {
                Button {
                    delete(location)
                } label: {
                    Label("Delete Location", systemImage: "trash")
                }
            }
        }
    }
    
    private func background(for colorScheme: ColorScheme) -> some View {
        Image(colorScheme == .light ? .lightBackground : .darkBackground)
            .resizable()
            .ignoresSafeArea(.all)
    }
    
    private func detailContentUnavailableView() -> some View {
        ContentUnavailableView(
            "No Location Selected",
            systemImage: "location.magnifyingglass",
            description: Text("Select a location to view more weather information.")
        )
    }
    
    private func addLocationView() -> some View {
        AddLocationView(
            adder: .init(
                locationsRepositoryFactory: DependencyFactory.shared.makeLocationsRepository,
                timeZoneRepositoryFactory: DependencyFactory.shared.makeTimeZoneRepository,
                weatherRepositoryFactory: DependencyFactory.shared.makeWeatherRepository
            ),
            addedLocation: Binding(
                get: { addedLocations },
                set: { addedLocations = $0 }
            )
        )
    }
}

#Preview {
    LocationsView(
        viewModel: .init(
            broadcaster: DependencyFactory.shared.makeUserLocationAuthorisationBroadcaster()
        )
    )
    .modelContainer(for: Location.self, inMemory: true)
}
