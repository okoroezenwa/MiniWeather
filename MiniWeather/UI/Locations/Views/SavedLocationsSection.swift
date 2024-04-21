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
    let onNicknameChange: (String, Int) -> Void
}

struct SavedLocationsSection: View {
    @Binding private var locations: [Location]
    private let viewModel: SavedLocationsSectionViewModel
    @State private var draggedItem: Location?
    @Binding private var selection: Location?
    @State private var isEditing = false
    @State private var editingIndices = Set<Int>()
    @State private var editingLocationInfo: EditLocationInfo?
    @State private var editInfo = SearchTextField.EditInfo(purpose: "", placeholder: "", text: "")
    @State private var showConfirmation = false
    @Environment(\.editMode) private var editMode
    @Environment(\.colorScheme) private var colorScheme
    
    init(locations: Binding<[Location]>, selection: Binding<Location?>, viewModel: SavedLocationsSectionViewModel) {
        self.viewModel = viewModel
        self._locations = locations
        self._selection = selection
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
                        action: {
                            let city = location.city
                            let nickname = location.nickname
                            let condition = nickname != city
                            editInfo = SearchTextField.EditInfo(purpose: "Edit Nickname", placeholder: city, text: nickname.value(if: condition) ?? "")
                            editingLocationInfo = .init(index: index, location: location)
                        }
                    )
                    
                    SwipeAction(
                        tint: .red,
                        name: "Delete Location",
                        icon: "trash.fill",
                        shouldResetPosition: false,
                        shouldGenerateFeedback: false,
                        action: { viewModel.onDelete(location) }
                    )
                } content: {
                    MaterialView(insets: .init(bottom: 12)) {
                        LocationCell(
                            location: location,
                            weather: viewModel.weather(location).wrappedValue,
                            isCurrentLocation: false,
                            shouldDisplayAsLoading: false
                        )
                    }
                } onSwipe: { isExpanded in
                    /*if isExpanded, !editingIndices.contains(index) {
                        editingIndices.insert(index)
                    } else if !isExpanded, editingIndices.contains(index) {
                        editingIndices.remove(index)
                    }*/
                }
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .leading))
            .simultaneousGesture(
                TapGesture()
                    .onEnded { value in
                        selection = location
                    }
            )
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
        .sheet(item: $editingLocationInfo) { item in
            SheetViewController(allowDismissal: editInfo.text.isEmpty && item.location.nickname == item.location.city) {
                showConfirmation = true
            } content: {
                EditNicknameView(location: item.location, index: item.index, editInfo: $editInfo, showConfirmation: $showConfirmation, onNicknameChange: viewModel.onNicknameChange) {
                    editingLocationInfo = nil
                }
                .preferredColorScheme(colorScheme)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: isEditing)
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
    SavedLocationsSection(locations: .constant([UniversalConstants.location]), selection: .constant(UniversalConstants.location), viewModel: .init(weather: { _ in .constant(UniversalConstants.weather) }, onDelete: { _ in }, onMove: { _, _ in }, onNicknameChange: { _, _ in }))
}

extension SavedLocationsSection {
    struct EditLocationInfo: Identifiable {
        let index: Int
        let location: Location
        
        var id: UUID { location.id }
    }
}
