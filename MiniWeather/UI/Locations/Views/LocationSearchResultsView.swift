//
//  LocationSearchResultsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct LocationSearchResultsView: View {
    @State var duplicateLocation: Location?
    @State var isShowingDuplicateAlert = false
    private var searchResults: [Location]
    private var isUniqueLocation: (Location) -> Bool
    private var addLocation: (Location) -> ()
    private var dismissSearch: () -> Void
    
    init(searchResults: [Location], isUniqueLocation: @escaping (Location) -> Bool, addLocation: @escaping (Location) -> Void, dismissSearch: @escaping () -> Void) {
        self.searchResults = searchResults
        self.isUniqueLocation = isUniqueLocation
        self.addLocation = addLocation
        self.dismissSearch = dismissSearch
    }
    
    var body: some View {
        List {
            ForEach(searchResults) { location in
                HStack {
                    Text(location.fullName)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .contentShape(
                    Rectangle()
                )
                .listRowSeparatorTint(.secondary.opacity(0.35))
                .listRowBackground(Color.clear)
                .onTapGesture {
                    guard isUniqueLocation(location) else {
                        duplicateLocation = location
                        isShowingDuplicateAlert = true
                        return
                    }
                    
                    withAnimation {
                        addLocation(location)
                    }
                    
                    dismissSearch()
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
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
}

#Preview {
    LocationSearchResultsView(
        searchResults: []
    ) { _ in
        false
    } addLocation: { _ in
        
    } dismissSearch: {
        
    }
}
