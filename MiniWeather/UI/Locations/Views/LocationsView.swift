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
    @Query(
        sort: \Location.timestamp,
        order: .reverse
    ) private var locations: [Location]
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
        .onChange(of: scenePhase) { oldValue, _ in
            if oldValue == .background {
                if let location = viewModel.getCurrentLocation(), location.isOutdated() {
                    viewModel.refreshCurrentLocation(requestingAuthorisation: false)
                } else {
                    viewModel.refreshStatus()
                }
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
    
    @ViewBuilder
    private func locationCell(for location: Location?, isCurrentLocation: Bool) -> some View {
        LocationCell(
            location: location,
            weather: {
                guard let location else {
                    return nil
                }
                return viewModel.weather(for: location).wrappedValue
            }(),
            isCurrentLocation: isCurrentLocation
        )
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            if !isCurrentLocation {
                Button {
                    guard let location else { return }
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
            LocationDetailView(
                location: location,
                weather: viewModel.weather(for: location)
            )
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
                guard viewModel.weather(for: location).wrappedValue == nil else {
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
                    viewModel.update(location) { timeZone in
                        location.timeZone = timeZone.name
                        try? modelContext.save()
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func currentLocationSection() -> some View {
        Section {
            if viewModel.getStatus().isAuthorised() {
                NavigationLink(value: viewModel.getCurrentLocation()) {
                    locationCell(for: viewModel.getCurrentLocation(), isCurrentLocation: true)
                        .padding(.horizontal, 16)
                }
            } else {
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
            HStack {
                Text("Current Location")
                    .font(
                        .system(size: 20, weight: .semibold)
                    )
                
                Spacer()
                
                if (viewModel.getCurrentLocation() == nil ||
                    viewModel.getCurrentLocation()?.isOutdated() == true),
                   viewModel.getStatus().isAuthorised()
                {
                    ProgressView()
                }
            }
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
