//
//  ToastView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/04/2024.
//

import SwiftUI

struct ToastView: View {
    var style: ToastStyle
    var title: String
    var message: String
    var rightButton: ToastButton?
    @State private var height: CGFloat = 20
    
    var body: some View {
        MaterialView(topPadding: 0, bottomPadding: 0, leadingPadding: 0, trailingPadding: 0) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: style.icon)
                    .foregroundColor(style.themeColor)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
                .overlay {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                DispatchQueue.main.async {
                                    height = proxy.size.height
                                }
                            }
                    }
                }
                
                if let rightButton {
                    Button {
                        rightButton.action()
                    } label: {
                        switch rightButton.style {
                            case .text(let title):
                                Text(title.uppercased())
                                    .lineLimit(1)
                                    .foregroundStyle(Color.primary)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            case .image(let symbol):
                                Image(systemName: symbol)
                                    .foregroundStyle(Color.primary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: height)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(.quinary)
                            .frame(width: 1.5)
                            .padding(.vertical, 16)
                    }
                }
                
            }
            .padding(.trailing, rightButton == nil ? 16 : 0)
        }
        .background(alignment: .leading) {
            Rectangle()
                .fill(style.themeColor)
                .frame(width: 12)
                .padding(.leading, 16)
                .padding(.vertical, 8)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

enum ToastStyle {
    case error
    case warning
    case success
    case info
    case delete
    case custom(color: Color, icon: String)
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
            case .error, .delete:
                return .red
            case .warning:
                return .orange
            case .info:
                return .blue
            case .success:
                return .green
            case .custom(color: let color, icon: _):
                return color
        }
    }
    
    var icon: String {
        switch self {
            case .info:
                return "info.circle.fill"
            case .warning:
                return "exclamationmark.triangle.fill"
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "xmark.circle.fill"
            case .delete:
                return "trash.circle.fill"
            case .custom(color: _, icon: let icon):
                return icon
        }
    }
}

enum ToastButtonStyle {
    case text(String)
    case image(String)
}

struct ToastButton {
    let style: ToastButtonStyle
    let action: (() -> Void)
}

struct Toast {//: Equatable {
    var style: ToastStyle
    var title: String
    var message: String
    var rightButton: ToastButton?
    var duration: Double = 7
}

#Preview {
    VStack(spacing: 8) {
        ToastView(
            style: .error,
            title: "Error",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ",
            rightButton: .init(
                style: .text("Undo")
            ) { }
        )
        
        ToastView(
            style: .info,
            title: "Info",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ")
        
        ToastView(
            style: .warning,
            title: "Warning",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ",
            rightButton: .init(
                style: .image("xmark")
            ) { }
        )
        
        ToastView(
            style: .success,
            title: "Success",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ")
    }
}

struct ToastModifier: ViewModifier {
    let toast: Toast?
    @Binding var isShowingToast: Bool
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack(alignment: .bottom) {
                    Color.clear
                    
                    if isShowingToast, let toast {
                        ToastView(
                            style: toast.style,
                            title: toast.title,
                            message: toast.message,
                            rightButton: toast.rightButton
                        )
                        .onTapGesture {
                            dismissToast()
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .offset(y: -10)
                    }
                }
                .animation(
                    .spring(),
                    value: isShowingToast
                )
            )
            .onChange(of: isShowingToast) {
                showToast()
            }
            .sensoryFeedback(.impact(weight: .light), trigger: isShowingToast) { _, newValue in
                return newValue
            }
    }
    
    private func showToast() {
        guard let toast else { return }
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            isShowingToast = false
        }
        
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toastView(toast: Toast?, isShowingToast: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(toast: toast, isShowingToast: isShowingToast))
    }
}
