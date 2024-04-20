//
//  SheetViewController.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 19/04/2024.
//

import SwiftUI

@MainActor
struct SheetViewController<T: View>: UIViewControllerRepresentable {
    let hostingController: UIHostingController<T>
    
    var onDismissAttempt: (() -> Void)?
    var allowDismissal: Bool // Don't use @Binding here. Only the initial value would be used.
    // The update will be handled in updateUIViewController().
    
    init(allowDismissal: Bool, onDismissAttempt: (() -> Void)? = nil, content: () -> T) {
        self.onDismissAttempt = onDismissAttempt
        self.hostingController = UIHostingController(rootView: content())
        self.allowDismissal = allowDismissal
    }
    
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        return self.hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {
        // These two lines are necessary to update allowDimsissal.
        context.coordinator.sheet = self
        uiViewController.rootView = self.hostingController.rootView
        uiViewController.parent?.presentationController?.delegate = context.coordinator
        (uiViewController.parent as? UIHostingController<AnyView>)?.safeAreaRegions = []
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var sheet: SheetViewController
        
        init(_ sheet: SheetViewController) {
            self.sheet = sheet
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            self.sheet.allowDismissal
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            self.sheet.onDismissAttempt?()
        }
    }
}
