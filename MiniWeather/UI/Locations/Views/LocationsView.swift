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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Query private var locations: [Location]
    @State private var isAddLocationViewVisible = false
    @State var addedLocations = [(location: Location, weather: Weather)]()
    @State var selectedLocation: Location?
    @State var viewModel: ViewModel

    var body: some View {
        NavigationSplitView {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible())],
                    alignment: .leading,
                    spacing: 12
                ) {
                    currentLocationSection()
                    
                    if !locations.isEmpty {
                        savedLocationsSection()
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddLocationViewVisible.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
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
        .onChange(of: scenePhase) { oldValue, _ in
            if oldValue == .background {
                viewModel.refreshStatus()
            }
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
    
    private func currentLocationSection() -> some View {
        Section {
            if let location = viewModel.getCurrentLocation() {
                locationCell(for: location, isCurrentLocation: true)
                    .padding(.bottom, 16)
            } else if !viewModel.getStatus().isAuthorised() {
                LocationAuthorisationCell(status: viewModel.getStatus())
                    .padding(.bottom, 16)
                    .onTapGesture {
                        let status = viewModel.getStatus()
                        if status.isDisallowed(),
                            let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        } else if status == .notDetermined {
                            viewModel.refreshCurrentLocation(requestingAuthorisation: true)
                        }
                    }
            }
        } header: {
            Text("Current Location")
                .font(
                    .system(size: 20, weight: .semibold)
                )
        }
    }
    
    private func savedLocationsSection() -> some View {
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

#Preview {
    LocationsView(
        viewModel: .init(
            userLocationAuthorisationRepositoryFactory: DependencyFactory.shared.makeUserLocationAuthorisationRepository,
            userLocationRepositoryFactory: DependencyFactory.shared.makeUserLocationRepository,
            locationsRepositoryFactory: DependencyFactory.shared.makeLocationsRepository
        )
    )
    .modelContainer(for: Location.self, inMemory: true)
}
