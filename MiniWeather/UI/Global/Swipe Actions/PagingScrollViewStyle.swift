//
//  PagingScrollViewStyle.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/04/2024.
//

import SwiftUI
import ScrollUI

struct PagingScrollViewStyle {
    @Binding private var context: ScrollContext
    
    init(context: Binding<ScrollContext>) {
        self._context = context
    }
}

extension PagingScrollViewStyle {
    class Coordinator: NSObject, ObservableObject {
        //MARK: - Properties
        @Binding var context: ScrollContext
        //MARK: - Initializers
        init(context: Binding<ScrollContext>) {
            self._context = context
        }
    }
}

extension PagingScrollViewStyle.Coordinator: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        Task { @MainActor in
            context.offset = scrollView.contentOffset
        }
    }
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        context.dragState = .started
        context.isScrolling = true
    }
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        context.dragState = .ending(velocity: velocity, targetOffset: targetContentOffset)
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        context.dragState = .ended(decelerating: decelerate)
        if !decelerate {
            context.isScrolling = false
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        context.isScrolling = false
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        context.isScrolling = false
        context.dragState = nil
    }
}

extension PagingScrollViewStyle: ScrollViewStyle {
    func makeCoordinator() -> Coordinator {
        return Coordinator(context: $context)
    }
    
    func make(uiScrollView: UIScrollView) {
        Task { @MainActor in
            uiScrollView.isPagingEnabled = true
        }
    }
}

extension ScrollViewStyle where Self == PagingScrollViewStyle {
    static func pagingStyle(_ context: Binding<ScrollContext>) -> PagingScrollViewStyle {
        return PagingScrollViewStyle(context: context)
    }
}
