//
//  ScrollViewWrapper.swift
//  FilmFX
//
//  Created by Paul Wong on 10/13/23.
//

import SwiftUI
import UIKit

struct ScrollViewWrapper<Content: View>: UIViewRepresentable {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = context.coordinator  // Set the delegate

        // Setup content view
        let hostVC = UIHostingController(rootView: content)
        hostVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostVC.view.backgroundColor = UIColor.clear
        scrollView.addSubview(hostVC.view)

        // Constraints: Note the absence of leading and trailing constraints here
        NSLayoutConstraint.activate([
            hostVC.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostVC.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostVC.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        // Setup content insets
        let sideInset = UIScreen.main.bounds.width / 2
        scrollView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        DispatchQueue.main.async {
            let contentView = uiView.subviews.first
            let totalWidth = contentView?.frame.width ?? 0

            // Update content size
            uiView.contentSize = CGSize(width: totalWidth, height: uiView.frame.height)

            // Center content offset if not set yet
            if uiView.contentOffset.x == 0 || context.coordinator.initialOffsetIsSet == false {
                let centerOffsetX = totalWidth/2 - uiView.frame.width/2
                uiView.contentOffset.x = centerOffsetX
                context.coordinator.initialOffsetIsSet = true
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var initialOffsetIsSet = false
        var lastOffset: CGFloat = 0
        var feedbackGenerator = UISelectionFeedbackGenerator()

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x

            // Check if contentOffset is within the allowed range
            let maxOffsetX = scrollView.contentSize.width - scrollView.frame.width + scrollView.contentInset.right
            let minOffsetX = -scrollView.contentInset.left

            if offset > minOffsetX && offset < maxOffsetX {
                let delta = offset - lastOffset

                if abs(delta) > 10 {
                    feedbackGenerator.selectionChanged()
                    lastOffset = offset - delta.truncatingRemainder(dividingBy: 10)
                }
            }
        }
    }
}
