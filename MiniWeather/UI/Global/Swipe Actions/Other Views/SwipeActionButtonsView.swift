//
//  SwipeActionButtonsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 20/04/2024.
//

import SwiftUI

struct SwipeActionButtonsView<S: SwipeActionStyle>: View {
    let direction: SwipeDirection
    let filteredActions: [SwipeAction]
    let style: S
    let isEditing: Bool
    @Binding var hasCrossedThreshold: Bool
    @Binding var allowUserInteraction: Bool
    @State var feedbackAction: SwipeAction?
    let currentActionButtonWidth: (Bool) -> CGFloat
    let currentOpacity: (Bool) -> CGFloat
    let currentScale: (Bool) -> CGSize
    let resetPosition: @MainActor (Bool) -> Void
    
    let constants = SwipeActionsConstants()
    var actionButtonsWidth: CGFloat {
        CGFloat(filteredActions.count) * constants.width
    }
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(width: actionButtonsWidth)
            .overlay(alignment: direction.alignment) {
                HStack(spacing: 0) {
                    ForEach(filteredActions) { swipeAction in
                        let isLastAction = swipeAction == filteredActions.last
                        
                        SwipeActionButton(
                            swipeAction: swipeAction,
                            widths: .init(
                                label: constants.width,
                                container: currentActionButtonWidth(isLastAction)
                            ),
                            visualEffects: .init(
                                opacity: currentOpacity(isLastAction),
                                scale: currentScale(isLastAction)
                            )
                        ) {
                            Task { @MainActor in
                                allowUserInteraction = false
                                
                                if !isEditing && swipeAction.shouldResetPosition {
                                    resetPosition(true)
                                    try? await Task.sleep(for: .seconds (0.25))
                                }
                                
                                if swipeAction.shouldGenerateFeedback {
                                    feedbackAction = swipeAction
                                }
                                
                                swipeAction.action()
                                try? await Task.sleep(for: .seconds (0.1))
                                allowUserInteraction = true
                                if !swipeAction.shouldResetPosition && !isEditing {
                                    try? await Task.sleep(for: .seconds (0.3))
                                    resetPosition(false)
                                }
                            }
                        } content: {
                            Label(swipeAction.name, systemImage: swipeAction.icon)
                                .labelStyle(.iconOnly)
                        }
                        .swipeActionStyle(style)
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                        .sensoryFeedback(.impact(weight: .medium), trigger: hasCrossedThreshold)
                        .sensoryFeedback(.impact(weight: .medium), trigger: feedbackAction)
                    }
                }
            }
    }
}
