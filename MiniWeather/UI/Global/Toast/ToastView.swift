//
//  ToastView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/04/2024.
//

import SwiftUI

struct ToastView: View {
    let toast: Toast
    @State private var height: CGFloat = 20
    
    var body: some View {
        MaterialView(topPadding: 0, bottomPadding: 0, leadingPadding: 0, trailingPadding: 0) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: toast.style.icon)
                    .foregroundColor(toast.style.themeColor)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(toast.title)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(toast.message)
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
                
                if let rightButton = toast.trailingButton {
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
            .padding(.trailing, toast.trailingButton == nil ? 16 : 0)
        }
        .background(alignment: .leading) {
            Rectangle()
                .fill(toast.style.themeColor)
                .frame(width: 12)
                .padding(.leading, 16)
                .padding(.vertical, 8)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 8) {
        ToastView(
            toast: Toast(
                style: .error,
                title: "Error",
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ",
                trailingButton: .init(
                    style: .text("Undo")
                ) { }
            )
        )
        
        ToastView(
            toast: Toast(
                style: .info,
                title: "Info",
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
            )
        )
        
        ToastView(
            toast: Toast(
                style: .warning,
                title: "Warning",
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ",
                trailingButton: .init(
                    style: .image("xmark")
                ) { }
            )
        )
        
        ToastView(
            toast: Toast(
                style: .success,
                title: "Success",
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
            )
        )
    }
}
