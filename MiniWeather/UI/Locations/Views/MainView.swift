//
//  MainView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import SwiftUI

@MainActor
struct MainView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @State var selectedLocation: Location?
    // TODO: - Replace alert with toast
    @State private var duplicateLocation: Location?
    @State private var isShowingSettings = false
    @State var viewModel: LocationsViewModel

    var body: some View {
        NavigationSplitView {
            LocationsView(hasSearchResults: viewModel.hasSearchResults()) { dismissSearch in
                LocationSearchResultsView(searchResults: viewModel.searchResults) { [weak viewModel] location in
                    guard let viewModel else {
                        return false
                    }
                    return !viewModel.locations.contains(where: { location.fullName == $0.fullName  })
                } addLocation: { [weak viewModel] location in
                    viewModel?.add(location)
                } dismissSearch: {
                    dismissSearch()
                }
            } gridView: {
                LocationsGridView(hasLocations: !viewModel.locations.isEmpty) {
                    SectionContainerView {
                        CurrentLocationSection(
                            viewModel: .init(
                                currentLocation: viewModel.currentLocation,
                                weather: {
                                    guard let location = viewModel.currentLocation else {
                                        return nil
                                    }
                                    return viewModel.weather(for: location).wrappedValue
                                }(),
                                authorisationStatus: viewModel.status, 
                                shouldDisplayAsLoading: viewModel.shouldDisplayProgressIndicator(),
                                notDetermined: { [weak viewModel] in
                                    viewModel?.refreshCurrentLocation(requestingAuthorisation: true)
                                }
                            )
                        )
                    } header: {
                            CurrentLocationSectionHeader(
                                shouldShowProgressView: viewModel.shouldDisplayProgressIndicator()
                            )
                    }
                } savedLocationsSection: {
                    SectionContainerView {
                        SavedLocationsSection(
                            viewModel: .init(
                                locations: viewModel.locations
                            ) { location in
                                viewModel.weather(for: location)
                            } onDelete: { [weak viewModel] location in
                                viewModel?.delete(location)
                            }
                        )
                    } header: {
                        SavedLocationsSectionHeader()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search City Name")
            .background {
                background(for: colorScheme)
            }
            .navigationTitle("Locations")
            .navigationDestination(for: Location.self) { [weak viewModel] location in
                if let viewModel {
                    WeatherView(
                        viewModel: .init(
                            location: location
                        ),
                        weather: viewModel.weather(for: location)
                    )
                    .preferredColorScheme(colorScheme)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.large)
                    #endif
                    .navigationTitle("Weather")
                }
            }
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
                .preferredColorScheme(colorScheme)
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
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            guard oldValue != newValue else { return }
            viewModel.search(for: newValue)
        }
        .onChange(of: scenePhase) { oldValue, _ in
            if oldValue == .background {
                if viewModel.isCurrentLocationOutdated() {
                    viewModel.refreshCurrentLocation(requestingAuthorisation: false)
                } else {
                    viewModel.refreshStatus()
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
}

#Preview {
    MainView(
        viewModel: .shared
    )
}
