import SwiftUI

#warning("Add documentation")
struct GestureSwipeActionsView<Content: View>: View {
    @State var offset: CGFloat = 0
    @State var startOffset: CGFloat = 0
    @State var isDragging = false
    @State var isTriggered = false
    
    let triggerThreshhold: CGFloat = -250
    let expansionThreshhold: CGFloat = -66
    let spacing: CGFloat = 16
    var expansionOffset: CGFloat { CGFloat(actions.count) * expansionThreshhold }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isEditing else {
                    return
                }
                
                if value.translation.width > 0, offset.isEqual(to: 0) {
                    return
                }
                
                if abs(value.translation.width) < abs(value.translation.height) {
                    return
                }
                
                if !isDragging {
                    startOffset = offset
                    isDragging = true
                }
                
                withAnimation(.interactiveSpring) {
                    offset = startOffset + value.translation.width
                }
                
                isTriggered = offset < triggerThreshhold
            }
            .onEnded { value in
                guard !isEditing else {
                    return
                }
                
                isDragging = false
                
                withAnimation {
                    if value.predictedEndTranslation.width < expansionThreshhold &&
                        !isTriggered {
                        offset = expansionOffset
//                        onManualInvocation(true)
                    } else {
                        if let action = actions.last, isTriggered {
                            action.action()
                        }
                        offset = 0
//                        onManualInvocation(false)
                    }
                }
                
                isTriggered = false
            }
    }
    
    private let style: ActionButton.Style
    private let actions: [Action]
    private let content: Content
    private let onManualInvocation: (Bool) -> Void
    private let isEditing: Bool
    
    init(
        style: ActionButton.Style,
        isEditing: Bool,
        actions: [Action],
        @ViewBuilder content: () -> Content,
        onManualInvocation: @escaping (Bool) -> Void
    ) {
        self.style = style
        self.actions = actions
        self.content = content()
        self.isEditing = isEditing
        self.onManualInvocation = onManualInvocation
    }
    
    var body: some View {
        content
            .overlay {
                Button {
                    if !isEditing, offset != 0 {
                        withAnimation {
                            offset = 0
                        }
                    }
                } label: {
                    Color.clear
                }
                .disabled(offset.isEqual(to: 0))
            }
            .offset(x: getOffset())
            .contentShape(.rect)
            .overlay(alignment: .trailing) {
                ZStack(alignment: .trailing) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                        let proportion = CGFloat(actions.count - index)
                        let isDefault = index == actions.count - 1
                        let needsLeadingPadding = actions.count > 1 && index == 0 // the first item from the leading edge will have the padding applied
                        let width = getWidth(isDefault: isDefault, proportion: proportion, needsLeadingPadding: needsLeadingPadding)
                        
                        ActionButton(
                            style: .rounded,
                            action: action,
                            width: width,
                            needsLeadingPadding: needsLeadingPadding
                        ) {
                            withAnimation {
                                offset = isEditing ? expansionOffset : 0
                            }
                        }
                        .opacity(isDefault ? 1 : isTriggered ? 0 : 1)
                    }
                }
                .animation(.spring, value: isTriggered)
                .sensoryFeedback(.impact(weight: .medium), trigger: isTriggered)
            }
            .highPriorityGesture(dragGesture)
            .onChange(of: isEditing) {
                withAnimation {
                    offset = isEditing ? expansionOffset : 0
                }
            }
    }
    
    func getOffset() -> CGFloat {
        // if the number of actions is over 1, we need leading padding. So we add that to the total offset
        let padding = actions.count > 1 ? spacing : 0
        let zeroOffsetValue = isEditing ? expansionOffset - padding : 0
        let expectedOffsetValue = isEditing ? expansionOffset : offset
        return offset == 0 ? 0 : expectedOffsetValue - padding
    }
    
    func getWidth(isDefault: Bool, proportion: CGFloat, needsLeadingPadding: Bool) -> CGFloat {
        isDefault && isTriggered ? -offset : (-offset * proportion / CGFloat(actions.count)) + (needsLeadingPadding ? spacing : 0)
    }
}

#Preview {
    GestureSwipeActionsView(style: .filled, isEditing: false, actions: [
        Action(color: .indigo, name: "Like", systemIcon: "hand.thumbsup.fill", action: {
            print("LIKE")
        }),
        Action(color: .blue, name: "Subscribe", systemIcon: "figure.mind.and.body", action: {
            print("SUBSCRIBE")
        }),
    ]) {
        Color.yellow
            .frame(height: 100)
            .font(.title)
    } onManualInvocation: { _ in
        
    }
}

struct Draggable<P: View>: ViewModifier {
    let condition: Bool
    let data: () -> NSItemProvider
    let preview: () -> P
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content
                .onDrag(data, preview: preview)
        } else {
            content
        }
    }
}
