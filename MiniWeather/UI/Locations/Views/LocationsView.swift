//
//  LocationsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import SwiftUI

@MainActor
struct LocationsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    @State var selectedLocation: Location?
    // TODO: - Replace alert with toast
    @State var duplicateLocation: Location?
    @State var viewModel: ViewModel
    @Binding var searchText: String
    @State var isShowingDuplicateAlert = false

    var body: some View {
        NavigationSplitView {
            rootView()
                .background {
                    background(for: colorScheme)
                }
        } detail: {
            background(for: colorScheme)
                .overlay {
                    detailContentUnavailableView()
                        .ignoresSafeArea(.keyboard)
                }
        }
        .task {
            do {
                try await viewModel.getSavedLocations()
                try await viewModel.getWeatherForSavedLocations()
            } catch {
                // TODO: - Replace with proper error-handling
                print(error.localizedDescription)
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            guard oldValue != newValue else { return }
            viewModel.search(for: newValue)
        }
        .onChange(of: scenePhase) { oldValue, _ in
            if oldValue == .background {
                if let location = viewModel.currentLocation, location.isOutdated() {
                    viewModel.refreshCurrentLocation(requestingAuthorisation: false)
                } else {
                    viewModel.refreshStatus()
                }
            }
        }
        .alert("Duplicate Location", isPresented: $isShowingDuplicateAlert, presenting: duplicateLocation) { _ in
            Button(role: .cancel) {
                isShowingDuplicateAlert = false
            } label: {
                Text("OK")
            }
        } message: { location in
            Text("You have already saved \"\(location.fullName)\".")
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
        #if os(iOS)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
        #endif
        .contextMenu {
            if !isCurrentLocation {
                Button(role: .destructive) {
                    guard let location else { return }
                    withAnimation {
                        viewModel.delete(location)
                    }
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
            LazyVStack(
                alignment: .leading,
                spacing: 12
            ) {
                currentLocationSection()
                
                if !viewModel.locations.isEmpty {
                    savedLocationsSection()
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Locations")
        .navigationDestination(for: Location.self) { location in
            LocationDetailView(
                location: location,
                weather: viewModel.weather(for: location)
            )
        }
        .toolbarBackground(.thinMaterial, for: .automatic)
        #if os(iOS)
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
        #endif
    }
    
    private func searchView() -> some View {
        List {
            ForEach(viewModel.searchResults) { location in
                HStack {
                    Text(location.fullName)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .listRowSeparatorTint(.secondary.opacity(0.35))
                .listRowBackground(Color.clear)
                .onTapGesture {
                    guard !viewModel.locations.contains(where: { location.fullName == $0.fullName  }) else {
                        duplicateLocation = location
                        isShowingDuplicateAlert = true
                        return
                    }
                    
                    withAnimation {
                        viewModel.add(location)
                    }
                    dismissSearch()
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }
    
    private func currentLocationSection() -> some View {
        Section {
            if viewModel.status.isAuthorised() {
                NavigationLink(value: viewModel.currentLocation) {
                    locationCell(for: viewModel.currentLocation, isCurrentLocation: true)
                        .padding(.horizontal, 16)
                }
            } else {
                LocationAuthorisationCell(status: viewModel.status)
                    .onTapGesture {
                        let status = viewModel.status
                        let string: String = {
                            #if os(iOS)
                            UIApplication.openSettingsURLString
                            #endif
                            return ""
                        }()
                        
                        if status.isDisallowed(),
                            let url = URL(string: string) {
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
                
                if (viewModel.currentLocation == nil ||
                    viewModel.currentLocation?.isOutdated() == true),
                   viewModel.status.isAuthorised()
                {
                    ProgressView()
                }
            }
            .padding([.top, .horizontal], 16)
        }
    }
    
    private func savedLocationsSection() -> some View {
        Section {
            ForEach(viewModel.locations) { location in
                NavigationLink(value: location) {
                    locationCell(for: location, isCurrentLocation: false)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .leading))
            }
            .animation(.easeInOut, value: viewModel.locations)
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
}
