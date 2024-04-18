//
//  DropViewDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/04/2024.
//

import SwiftUI

struct DropViewDelegate<Item: Equatable>: DropDelegate {
    let destinationItem: Item
    @Binding var locations: [Item]
    @Binding var draggedItem: Item?
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
