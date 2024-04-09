//
//  ToastModifier.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/04/2024.
//

import SwiftUI

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
                        ToastView(toast: toast)
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
