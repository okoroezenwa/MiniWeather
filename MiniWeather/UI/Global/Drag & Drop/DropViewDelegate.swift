//
//  DropViewDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 17/04/2024.
//

import SwiftUI

struct DropViewDelegate<Item: Equatable>: DropDelegate {
    let destinationItem: Item
    @Binding var items: [Item]
    @Binding var draggedItem: Item?
    let onMove: (IndexSet, Int) -> Void
    let onMoveCompleted: () -> Void
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onMoveCompleted()
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        if let draggedItem,
            let fromIndex = items.firstIndex(of: draggedItem),
           let toIndex = items.firstIndex(of: destinationItem),
           fromIndex != toIndex
        {
            let offsets = IndexSet(integer: fromIndex)
            let destination = (toIndex > fromIndex ? (toIndex + 1) : toIndex)
//            withAnimation {
//                self.items.move(fromOffsets: offsets, toOffset: destination)
//            }
            onMove(offsets, destination)
        }
    }
}
