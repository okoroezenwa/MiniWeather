//
//  ActionButton.swift
//  SwipeActionsFromScratch
//
//  Created by Kit Langton on 9/20/23.
//

import SwiftUI

struct ActionButton: View {
    enum Style: String {
        case filled, rounded
    }
    
    let style: Style
    let action: Action
    let width: CGFloat
    let needsLeadingPadding: Bool
    let dismiss: () -> Void
    let colours = [Color.red, .green]
    
    let spacing: CGFloat = 16
    
    var body: some View {
        Button {
            action.action()
            dismiss()
        } label: {
            switch style {
                case .filled:
                    filledStyle()
                case .rounded:
                    roundedStyle()
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder func filledStyle() -> some View {
        action.color
            .overlay(alignment: .leading) {
                Label(action.name, systemImage: action.systemIcon)
                    .labelStyle(.iconOnly)
                    .padding(.leading)
            }
            .clipped()
            .frame(width: width)
            .font(.title2)
    }
    
    @ViewBuilder func roundedStyle() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                Color.clear
                    .overlay(alignment: .leading) {
                        Circle()
                            .frame(width: 50)
                            .foregroundStyle(action.color)
                            .overlay {
                                Label(action.name, systemImage: action.systemIcon)
                                    .labelStyle(.iconOnly)
                            }
                            .padding(.leading, needsLeadingPadding ? spacing : 0)
                    }
                    .clipShape(.rect(cornerRadii: .init(topLeading: 25, bottomLeading: 25)))
                    .frame(width: width < 0 ? 0 : width, height: 50)
                    .font(.title2)
            }
            
            Spacer()
        }
        .contentShape(.rect)
    }

}

struct Action {
    let color: Color
    let name: String
    let systemIcon: String
    let action: () -> Void
}
