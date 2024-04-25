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
    @State private var duplicateLocation: Location?
    @State private var isShowingSettings = false
    @State var viewModel: LocationsViewModel
    @AppStorage(Settings.maxLocations) private var maxLocations = LocationsCount.max

    var body: some View {
        NavigationSplitView {
            LocationsView(
                hasSearchResults: viewModel.hasSearchResults(),
                searchView: locationsSearchView,
                gridView: locationsGridView
            )
            .searchable(text: $viewModel.searchText, prompt: "Search City Name")
            .refreshable {
                if viewModel.status.isAuthorised() {
                    viewModel.refreshCurrentLocation(requestingAuthorisation: false)
                }
                #warning("Fix viewModel later")
                do {
                    try await viewModel.getWeatherForSavedLocations()
                } catch {
                    print(error)
                }
            }
            .background {
                background(for: colorScheme)
            }
            .navigationTitle("Locations")
            .navigationDestination(for: Location.self) { [weak viewModel] location in
                if let viewModel {
                    weatherView(location, viewModel: viewModel)
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
            .sensoryFeedback(.impact(weight: .medium), trigger: isShowingSettings) { oldValue, newValue in
                oldValue != newValue && newValue
            }
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
        .toastView(toast: $viewModel.displayedToast)
        .sensoryFeedback(.selection, trigger: selectedLocation)
        .onChange(of: maxLocations) {
            viewModel.updateLocationsOnMaxLocationChange()
        }
    }
    
    private func locationsSearchView(_ dismissSearch: @escaping () -> Void) -> some View {
        LocationSearchResultsView(searchResults: viewModel.searchResults) { [weak viewModel] location in
            guard let viewModel else {
                return false
            }
            return !viewModel.locations.contains(where: { location.fullName == $0.fullName  })
        } addLocation: { [weak viewModel] location in
            viewModel?.displayToastForAdditionOf(location)
        } dismissSearch: {
            dismissSearch()
        } onDuplicateFound: { [weak viewModel] location in
            let toast = Toast(style: .warning, title: "Duplicate Location", message: "You have already saved \(location.nickname) to Locations".grantAttributes(to: location.nickname, values: Location.toastMessageAttributeValues))
            viewModel?.setToast(to: toast)
        }
    }
    
    private func locationsGridView() -> some View {
        LocationsGridView(hasLocations: !viewModel.locations.isEmpty) {
            SectionContainerView {
                CurrentLocationSection(
                    selection: $selectedLocation,
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
                    locations: $viewModel.locations,
                    selection: $selectedLocation,
                    viewModel: SavedLocationsSectionViewModel { location in
                        viewModel.weather(for: location)
                    } onDelete: { [weak viewModel] location in
                        viewModel?.displayToastForRemovalOf(location)
                    } onMove: { offsets, destination in
                        viewModel.move(from: offsets, to: destination)
                    } onNicknameChange: { nickname, index in
                        viewModel.editNickname(ofLocationAt: index, to: nickname)
                    }
                )
            } header: {
                SavedLocationsSectionHeader()
            }
        }
    }
    
    private func weatherView(_ location: Location, viewModel: LocationsViewModel) -> some View {
        WeatherView(
            viewModel: .init(
                location: location
            ),
            weather: viewModel.weather(for: location)
        )
        .preferredColorScheme(colorScheme)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WeatherCardTrailingHeaderTextView(text: Date.now.in(timeZone: .from(identifier: location.timeZoneIdentifier ?? .empty)).formatted(date: .omitted, time: .shortened))
                    .padding(.trailing, 8)
            }
        }
        #endif
        .navigationTitle(location.nickname)
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
        viewModel: LocationsViewModel(
            preferencesRepositoryFactory: DependencyFactory.shared.makePreferencesRepository, 
            userLocationAuthorisationRepositoryFactory: DependencyFactory.shared.makeUserLocationAuthorisationRepository,
            userLocationCoordinatesRepositoryFactory: DependencyFactory.shared.makeUserLocationCoordinatesRepository,
            locationsRepositoryFactory: DependencyFactory.shared.makeLocationsSearchRepository,
            weatherRepositoryFactory: DependencyFactory.shared.makeWeatherRepository,
            timeZoneRepositoryFactory: DependencyFactory.shared.makeTimeZoneRepository,
            currentLocationRepositoryFactory: DependencyFactory.shared.makeCurrentLocationRepository,
            savedLocationsRepositoryFactory: DependencyFactory.shared.makeSavedLocationsRepository
        )
    )
}
