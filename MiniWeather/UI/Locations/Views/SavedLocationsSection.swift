//
//  SavedLocationsSection.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI

struct SavedLocationsSectionViewModel {
    let weather: (Location) -> Binding<WeatherProtocol?>
    let onDelete: (Location) -> Void
    let onMove: (IndexSet, Int) -> Void
}

struct SavedLocationsSection: View {
    @Binding private var locations: [Location]
    private let viewModel: SavedLocationsSectionViewModel
    
    @State private var draggedItem: Location?
    @State private var isEditing = false
    @State private var editingIndices = Set<Int>()
    @Environment(\.editMode) private var editMode
    
    init(locations: Binding<[Location]>, viewModel: SavedLocationsSectionViewModel) {
        self.viewModel = viewModel
        self._locations = locations
    }
    
    var body: some View {
        ForEach(array(), id: \.location) { index, location in
            NavigationLink(value: location) {
                ScrollSwipeActionsView(
                    direction: .trailing,
                    style: .translucentRounded,
                    isEditing: $isEditing
                ) {
                    SwipeAction(
                        tint: .blue,
                        name: "Edit Location Name",
                        icon: "pencil",
                        action: { }
                    )
                    
                    SwipeAction(
                        tint: .red,
                        name: "Delete Location",
                        icon: "trash.fill",
                        shouldResetPosition: false,
                        action: { viewModel.onDelete(location) }
                    )
                } content: {
                    MaterialView(bottomPadding: 12) {
                        LocationCell(
                            location: location,
                            weather: viewModel.weather(location).wrappedValue,
                            isCurrentLocation: false,
                            shouldDisplayAsLoading: false
                        )
                    }
                } onSwipe: { isExpanded in
//                    if isExpanded, !editingIndices.contains(index) {
//                        editingIndices.insert(index)
//                    } else if !isExpanded, editingIndices.contains(index) {
//                        editingIndices.remove(index)
//                    }
                }
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .leading))
            .onDrag /*(if: /*!isEditing && !editingIndices.contains(index)*/true)*/ {
                draggedItem = location
                return NSItemProvider()
            } preview: {
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(.white)
                    .opacity(0.1)
            }
            .onDrop(of: [.location], delegate: DropViewDelegate(destinationItem: location, locations: $locations, draggedItem: $draggedItem, onMove: viewModel.onMove))
        }
        .animation(.smooth, value: locations)
        .padding(.horizontal, 16)
        .onChange(of: editMode?.wrappedValue.isEditing) {
            isEditing = editMode?.wrappedValue.isEditing == true
        }
    }
    
    func array() -> [(index: Int, location: Location)] {
        Array(zip(0..<locations.count, locations))
    }
    
    func actions(for location: Location) -> [Action] {
        [
            Action(
                color: .blue,
                name: "Edit Location Name",
                systemIcon: "pencil",
                action: { }
            ),
            Action(
                color: .red,
                name: "Delete Location",
                systemIcon: "trash.fill",
                action: { viewModel.onDelete(location) }
            )
        ]
    }
}

#Preview {
    SavedLocationsSection(locations: .constant([UniversalConstants.location]), viewModel: .init(weather: { _ in .constant(UniversalConstants.weather) }, onDelete: { _ in }, onMove: { _, _ in }))
}
