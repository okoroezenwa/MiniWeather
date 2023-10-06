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
    @Bindable var adder: LocationsAdder
    
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
                
                List {
                    ForEach(adder.locations) { location in
                        HStack {
                            Text(location.city)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            adder.add(location, to: modelContext)
                            dismiss()
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
        }
    }
}

#Preview {
    AddLocationView(
        adder: .init(
            locationsRepository: MainLocationsRepository(
                geocodeService: MainGeocodeService()
            )
        )
    )
}
