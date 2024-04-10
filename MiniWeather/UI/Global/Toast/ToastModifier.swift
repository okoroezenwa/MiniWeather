//
//  ToastModifier.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 09/04/2024.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack(alignment: .bottom) {
                    Color.clear
                    
                    if let toast {
                        ToastView(toast: toast)
                            .onTapGesture {
                                dismissToast()
                            }
                            .transition(.move(edge: .bottom)/*.combined(with: .opacity)*/)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 1)
                            .padding(.bottom, 30)
                            .padding(.horizontal, 16)
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .animation(
                    .spring(),
                    value: toast
                )
            }
            .onChange(of: toast) {
                showToast()
            }
            .sensoryFeedback(.impact(weight: .light), trigger: toast) { _, newValue in
                return newValue != nil
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
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}
