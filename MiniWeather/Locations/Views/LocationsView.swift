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

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(locations) { location in
                    HStack {
                        Text("\(location.city), \(location.country)")
                        
                        Spacer()
                    }
                }
                .onDelete(perform: deleteItems(offsets:))
            }
            .navigationTitle("Locations")
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        isAddLocationViewVisible.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                    EditButton()
                }
            }
        } detail: {
            
        }
        .sheet(isPresented: $isAddLocationViewVisible) {
            AddLocationView(
                adder: .init(
                    locationsRepository: 
                        MainLocationsRepository(
                            geocodeService: MainGeocodeService()
                        )
                )
            )
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
