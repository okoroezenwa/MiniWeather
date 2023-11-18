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
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    @Query(sort: \Location.timestamp, order: .reverse) private var locations: [Location]
    @State private var isAddLocationViewVisible = false
    @State var addedLocations = [(location: Location, weather: Weather)]()
    @State var selectedLocation: Location?
    @State var viewModel: ViewModel
    @Binding var searchText: String

    var body: some View {
        NavigationSplitView {
            rootView()
                .background {
                    background(for: colorScheme)
                }
        } detail: {
            detailContentUnavailableView()
                .background {
                    background(for: colorScheme)
                }
                .ignoresSafeArea(.keyboard)
        }
        .onChange(of: searchText) { oldValue, newValue in
            guard oldValue != newValue else { return }
            viewModel.search(for: newValue)
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
    
    // MARK: - SwiftData
    private func add(_ location: Location) {
        withAnimation {
            modelContext.insert(location)
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
    @ViewBuilder
    private func rootView() -> some View {
        if searchText.isEmpty {
            locationsGrid()
        } else {
            searchView()
        }
    }
    
    private func locationCell(for location: Location, isCurrentLocation: Bool) -> some View {
        LocationCell(
            location: location,
            weather: viewModel.weather(for: location),
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
    
    private func locationsGrid() -> some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(
                        .flexible()
                    )
                ],
                alignment: .leading,
                spacing: 12
            ) {
                currentLocationSection()
                
                if !locations.isEmpty {
                    savedLocationsSection()
                }
            }
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
                EditButton()
            }
        }
        .onAppear {
            locations.forEach { location in
                guard viewModel.weather(for: location) == nil else {
                    return
                }
                viewModel.getWeather(for: location)
            }
        }
    }
    
    private func searchView() -> some View {
        List {
            ForEach(viewModel.getSearchResults()) { location in
                HStack {
                    Text(location.fullName)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .listRowSeparatorTint(.secondary.opacity(0.35))
                .listRowBackground(Color.clear)
                .onTapGesture {
                    add(location)
                    dismissSearch()
                    viewModel.update(location)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func currentLocationSection() -> some View {
        Section {
            if let location = viewModel.getCurrentLocation() {
                NavigationLink(value: location) {
                    locationCell(for: location, isCurrentLocation: true)
                        .padding(.horizontal, 16)
                }
            } else if !viewModel.getStatus().isAuthorised() {
                LocationAuthorisationCell(status: viewModel.getStatus())
                    .onTapGesture {
                        let status = viewModel.getStatus()
                        if status.isDisallowed(),
                            let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        } else if status == .notDetermined {
                            viewModel.refreshCurrentLocation(requestingAuthorisation: true)
                        }
                    }
                    .padding(.horizontal, 16)
            }
        } header: {
            Text("Current Location")
                .font(
                    .system(size: 20, weight: .semibold)
                )
                .padding([.top, .horizontal], 16)
        }
    }
    
    private func savedLocationsSection() -> some View {
        Section {
            ForEach(locations) { location in
                NavigationLink(value: location) {
                    locationCell(for: location, isCurrentLocation: false)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Saved Locations")
                .font(
                    .system(size: 20, weight: .semibold)
                )
                .padding([.horizontal, .top], 16)
        }
    }
}

#Preview {
    LocationsView(
        viewModel: .shared, 
        searchText: Binding(get: { "" }, set: { _ in })
    )
    .modelContainer(for: Location.self, inMemory: true)
}
