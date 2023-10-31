//
//  AddLocationView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/10/2023.
//

import SwiftUI

struct AddLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var adder: LocationsAdder
    @Binding var addedLocation: [(location: Location, weather: Weather)]
    @FocusState private var isFocused
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField(
                    "Enter City Name",
                    text: $adder.searchString
                )
                .textFieldStyle(.roundedBorder)
                .onChange(of: adder.searchString) { oldValue, newValue in
                    adder.search(for: newValue)
                }
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
                
                List {
                    ForEach(adder.locations) { location in
                        HStack {
                            Text(location.fullName)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                var newLocation = location
                                if location.timeZone.isEmpty {
                                    newLocation = try await adder.getNewLocationWithUpdatedTimeZone(for: location)
                                }
                                
                                let weather = try await adder.getWeather(for: location)
                                addedLocation.append((newLocation, weather))
                                
                                await MainActor.run {
                                    adder.add(newLocation, to: modelContext)
                                    dismiss()
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitle("Add Location", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .padding(16)
            .background {
                Image(colorScheme == .light ? .lightBackground : .darkBackground)
                    .resizable()
                    .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    AddLocationView(
        adder: .init(
            locationsRepositoryFactory: DependencyFactory.shared.makeLocationsRepository,
            timeZoneRepositoryFactory: DependencyFactory.shared.makeTimeZoneRepository,
            weatherRepositoryFactory: DependencyFactory.shared.makeWeatherRepository
        ), 
        addedLocation: Binding(
            get: { [] },
            set: { _ in }
        )
    )
}
