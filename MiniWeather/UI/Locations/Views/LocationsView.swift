//
//  LocationsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct LocationsView<Search: View, Grid: View>: View {
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    private let hasSearchResults: Bool
    @ViewBuilder private let searchView: (@escaping () -> Void) -> Search
    @ViewBuilder private let gridView: () -> Grid
    
    init(hasSearchResults: Bool, searchView: @escaping (@escaping () -> Void) -> Search, gridView: @escaping () -> Grid) {
        self.searchView = searchView
        self.gridView = gridView
        self.hasSearchResults = hasSearchResults
    }
    
    var body: some View {
        mainView()
            .sensoryFeedback(.impact(weight: .medium), trigger: isSearching)
    }
    
    @ViewBuilder func mainView() -> some View {
        if isSearching && hasSearchResults {
            searchView() {
                dismissSearch()
            }
        } else {
            gridView()
        }
    }
}

#Preview {
    LocationsView(hasSearchResults: true) { _ in
        EmptyView()
    } gridView: {
        EmptyView()
    }
}
