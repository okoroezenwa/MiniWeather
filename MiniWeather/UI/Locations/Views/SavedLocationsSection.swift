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
    
    init(locations: Binding<[Location]>, viewModel: SavedLocationsSectionViewModel) {
        self.viewModel = viewModel
        self._locations = locations
    }
    
    var body: some View {
        ForEach(locations) { location in
            NavigationLink(value: location) {
                MaterialView(bottomPadding: 12) {
                    LocationCell(
                        location: location,
                        weather: viewModel.weather(location).wrappedValue,
                        isCurrentLocation: false,
                        shouldDisplayAsLoading: false
                    )
                } /*background: {
                    HStack(spacing: 16) {
                        Spacer()
                        
                        Circle()
                            .frame(square: 35)
                            .background(.thinMaterial)
                            .overlay {
                                Image(systemName: "trash.fill")
                            }
                    }
                    .padding(.trailing, 16)
                }*/
//                #if os(iOS)
//                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
//                #endif
//                .contextMenu {
//                    Button(role: .destructive) {
//                        withAnimation {
//                            viewModel.onDelete(location)
//                        }
//                    } label: {
//                        Label("Delete Location", systemImage: "trash")
//                    }
//                }
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .leading))
            .onDrag {
                draggedItem = location
                return NSItemProvider()
            } preview: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .opacity(0.1)
            }
            .onDrop(of: [.location], delegate: DropViewDelegate(destinationItem: location, locations: $locations, draggedItem: $draggedItem, onMove: viewModel.onMove))
        }
        .animation(.easeInOut, value: locations)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SavedLocationsSection(locations: .init(get: { [UniversalConstants.location] }, set: { _ in }), viewModel: .init(weather: { _ in Binding(get: { UniversalConstants.weather }, set: { _ in }) }, onDelete: { _ in }, onMove: { _, _ in }))
}

struct DropViewDelegate: DropDelegate {
    
    let destinationItem: Location
    @Binding var locations: [Location]
    @Binding var draggedItem: Location?
    var onMove: (IndexSet, Int) -> Void
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        if let draggedItem, 
            let fromIndex = locations.firstIndex(of: draggedItem),
            let toIndex = locations.firstIndex(of: destinationItem),
            fromIndex != toIndex
        {
            let offsets = IndexSet(integer: fromIndex)
            let destination = (toIndex > fromIndex ? (toIndex + 1) : toIndex)
            withAnimation {
                self.locations.move(fromOffsets: offsets, toOffset: destination)
            }
            onMove(offsets, destination)
        }
    }
}
