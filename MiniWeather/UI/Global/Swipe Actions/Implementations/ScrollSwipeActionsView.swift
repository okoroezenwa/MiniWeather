//
//  ScrollSwipeActionsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 14/04/2024.
//

import SwiftUI
import ScrollUI

struct ScrollSwipeActionsView<Content: View, Style: SwipeActionStyle>: View {
    let contentID = UUID()
    let swipeActionsViewID = UUID()
    let width: CGFloat = 66
    let triggerThreshold: CGFloat = 200
    let animation = Animation.smooth(duration: 0.25)
    let direction: SwipeDirection
    let style: Style
    let onSwipe: (Bool) -> Void
    var actionButtonsWidth: CGFloat {
        CGFloat(filteredActions.count) * width
    }
    var filteredActions: [SwipeAction] {
        actions.filter(\.isEnabled)
    }
    @State var allowUserInteraction = true
    @State var hasCrossedThreshold = false
    @State var scrollOffset: CGFloat = 0
    @Binding var isEditing: Bool
    @ActionBuilder let actions: [SwipeAction]
    @ViewBuilder let content: Content
    @ScrollState var scrollState
    
    init(direction: SwipeDirection, style: Style, isEditing: Binding<Bool>, @ActionBuilder actions: () -> [SwipeAction], @ViewBuilder content: () -> Content, onSwipe: @escaping (Bool) -> Void) {
        self.direction = direction
        self._isEditing = isEditing
        self.actions = actions()
        self.content = content()
        self.style = style
        self.onSwipe = onSwipe
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    content
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                        .containerRelativeFrame(.horizontal)
                        .id(contentID)
                        .overlay {
                            Button {
                                if !isEditing {
                                    resetPosition(with: proxy, shouldAnimate: true)
                                }
                            } label: {
                                Color.clear
                            }
                            .disabled(scrollOffset.isEqual(to: 0))
                        }
                    
                    ActionButtons { animated in
                        resetPosition(with: proxy, shouldAnimate: animated)
                    }
                }
                .scrollTargetLayout()
                .visualEffect { content, innerProxy in
                    content
                        .offset(x: scroll0ffset(innerProxy))
                }
            }
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollDisabled(isEditing)
            .background(alignment: .trailing) {
                if style is FilledSwipeActionStyle, let lastAction = filteredActions.last {
                    Rectangle()
                        .fill(lastAction.tint)
                        .frame(width: scrollOffset)
                }
            }
            .rotationEffect(.init(degrees: direction == .leading ? 180 : 0))
            .scrollViewStyle(.pagingStyle($scrollState))
            .onChange(of: scrollState.isDragging) { oldValue, newValue in
                if !newValue, hasCrossedThreshold, let lastAction = filteredActions.last {
                    lastAction.action()
                    withAnimation(.smooth) {
                        proxy.scrollTo(contentID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                    }
                }
            }
            .onChange(of: isEditing) { _, newValue in
                withAnimation {
                    if newValue {
                        proxy.scrollTo(swipeActionsViewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                    } else {
                        proxy.scrollTo(contentID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                    }
                }
            }
//            .onChange(of: scrollOffset) { _, newValue in
//                onSwipe(abs(newValue) >= actionButtonsWidth)
//            }
        }
        .allowsHitTesting(allowUserInteraction)
    }
    
    func resetPosition(with proxy: ScrollViewProxy, shouldAnimate: Bool) {
        if shouldAnimate {
            withAnimation(.smooth(duration: 0.25)) {
                proxy.scrollTo(contentID, anchor: direction == .trailing ? .topLeading : .topTrailing)
            }
        } else {
            proxy.scrollTo(contentID, anchor: direction == .trailing ? .topLeading : .topTrailing)
        }
    }
    
    @ViewBuilder
    func ActionButtons(resetPosition: @escaping @MainActor (Bool) -> Void) -> some View {
        Rectangle()
            .fill(.clear)
            .id(swipeActionsViewID)
            .frame(width: actionButtonsWidth)
            .overlay(alignment: direction.alignment) {
                HStack(spacing: 0) {
                    ForEach(filteredActions) { swipeAction in
                        let isLastAction = swipeAction == filteredActions.last
                        
                        SwipeActionButton(
                            swipeAction: swipeAction,
                            widths: .init(
                                label: width,
                                container: getActionButtonWidth(isLastAction: isLastAction)
                            ),
                            visualEffects: .init(
                                opacity: getOpacity(isLastAction: isLastAction),
                                scale: getScale(isLastAction: isLastAction)
                            )
                        ) {
                            Task { @MainActor in
                                allowUserInteraction = false
                                if !isEditing && swipeAction.shouldResetPosition {
                                    resetPosition(true)
                                    try? await Task.sleep(for: .seconds (0.25))
                                }
                                swipeAction.action()
                                try? await Task.sleep(for: .seconds (0.1))
                                allowUserInteraction = true
//                                if !swipeAction.shouldResetPosition && !isEditing {
//                                    try? await Task.sleep(for: .seconds (0.25))
//                                    resetPosition(false)
//                                }
                            }
                        } content: {
                            Label(swipeAction.name, systemImage: swipeAction.icon)
                                .labelStyle(.iconOnly)
                        }
                        .swipeActionStyle(style)
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                        .sensoryFeedback(.impact(weight: .medium), trigger: hasCrossedThreshold)
                    }
                }
            }
    }
    
    func getActionButtonWidth(isLastAction: Bool) -> CGFloat {
        if isLastAction {
            hasCrossedThreshold ? actionButtonsWidth : width
        } else {
            hasCrossedThreshold ? 0 : width
        }
    }
    
    func getOpacity(isLastAction: Bool) -> CGFloat {
        if isLastAction {
            1
        } else {
            hasCrossedThreshold ? 0 : 1
        }
    }
    
    func getScale(isLastAction: Bool) -> CGSize {
        if isLastAction {
            .init(width: 1, height: 1)
        } else {
            hasCrossedThreshold ? .init(width: 0.2, height: 0.2) : .init(width: 1, height: 1)
        }
    }
    
    func scroll0ffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        Task {
            let absoluteMinX = abs(minX)
            scrollOffset = absoluteMinX
            withAnimation(.smooth(duration: 0.25)) {
                hasCrossedThreshold = absoluteMinX > triggerThreshold
            }
        }
        return (minX > 0 ? -minX : 0)
    }
}

#Preview {
    ColorList()
}

@resultBuilder
struct ActionBuilder {
    static func buildBlock(_ components: SwipeAction...) -> [SwipeAction] {
        return components
    }
}

struct ColorList: View {
    @State var colors = [Color.yellow, .black, .green, .pink, .purple]
    @State var isEditing = false
    @Environment(\.editMode) var editMode
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 16) {
                    ForEach(Array(zip(0..<colors.count, colors)), id: \.1) { index, color in
                        ScrollSwipeActionsView(direction: .trailing, style: .rounded, isEditing: $isEditing) {
                            SwipeAction(tint: .blue, name: "Edit Item", icon: "star.fill") {
                                print("Bookmarked")
                            }
                            SwipeAction(tint: .red, name: "Delete Item", icon: "trash.fill", shouldResetPosition: false) {
                                colors.remove(at: index)
                            }
                        } content: {
                            color
                                .overlay {
                                    Text("Hey")
                                        .foregroundStyle(.white)
                                }
                                .clipShape(.rect(cornerRadius: 16))
                        } onSwipe: { _ in
                            
                        }
                        .frame(height: 100)
                        .transition(.move(edge: .leading))
                        .shadow(color: .black.opacity(0.15), radius: 20)
                    }
                    .animation(.easeInOut, value: colors)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Colours")
            .toolbarBackground(.thinMaterial, for: .automatic)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            #endif
        }
    }
}
