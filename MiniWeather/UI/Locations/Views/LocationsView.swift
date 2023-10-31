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
    @Query private var locations: [Location]
    @State private var isAddLocationViewVisible = false
    @State var addedLocations = [(location: Location, weather: Weather)]()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationSplitView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(locations) { location in
                            LocationCell(
                                location: location,
                                weather: addedLocations.first { $0.location == location }?.weather
                            )
                            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
                            .contextMenu {
                                Button {
                                    delete(location)
                                } label: {
                                    Label("Delete Location", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .background {
                    Image(colorScheme == .light ? .lightBackground : .darkBackground)
                        .resizable()
                        .ignoresSafeArea(.all)
                }
                .navigationTitle("Locations")
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
                        ContentUnavailableView("No Cities Added", systemImage: "line.horizontal.3.circle", description: Text("Searched cities you add will appear here."))
                    }
                }
        } detail: {
            
        }
        .sheet(isPresented: $isAddLocationViewVisible) {
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
}

#Preview {
    LocationsView()
        .modelContainer(for: Location.self, inMemory: true)
}
