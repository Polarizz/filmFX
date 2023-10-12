//
//  ViewFinder.swift
//  FilmFX
//
//  Created by Paul Wong on 10/11/23.
//

import SwiftUI
import UIKit

class PageModel: ObservableObject {
    @Published var currentPage: Int = 0
}

class ZoomScale: ObservableObject {
    @Published var scale: CGFloat = 1.0
}

struct ViewFinder: View {

    @Environment(\.safeAreaInsets) var safeAreaInsets

    @StateObject private var zoomScale = ZoomScale()
    @StateObject private var pageModel = PageModel()

    let frameWidth: CGFloat = UIScreen.main.bounds.maxX
    let totalFrames: Int = 20
    let frameSpacing: CGFloat = 7
    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3

    @State var selectedFrames = Set<Int>()

    var body: some View {
        ZoomAndPanView(totalFrames: CGFloat(totalFrames), frameSpacing: frameSpacing, zoomScale: zoomScale, pageModel: pageModel) {
            HStack(spacing: frameSpacing) {
                ForEach(0..<totalFrames, id: \.self) { index in
                    RoundedRectangleView(zoomScale: zoomScale, isSelected: selectedFrames.contains(index)) {
                        handleTap(for: index)
                    }
                }
            }
            .offset(y: -40)
        }
        .ignoresSafeArea(.container)
        .background(.black)
        .overlay(
            Text("^[\(selectedFrames.count) FRAME](inflect: true) SELECTED")
                .font(.footnote.weight(.medium))
                .foregroundColor(.black)
                .padding(.vertical, 5)
                .padding(.horizontal, 7)
                .background(.yellow)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .transformEffect(.identity)
                .padding(16)
                .opacity(selectedFrames.count > 0 ? 1 : 0)
            , alignment: .top
        )
    }

    private func handleTap(for index: Int) {
        if selectedFrames.contains(index) {
            selectedFrames.removeAll()
        } else if let minSelected = selectedFrames.min(), let maxSelected = selectedFrames.max() {
            if index < minSelected {
                selectedFrames.formUnion(Set((index...minSelected)).subtracting(selectedFrames))
            } else if index > maxSelected {
                selectedFrames.formUnion(Set((maxSelected...index)).subtracting(selectedFrames))
            }
        } else {
            selectedFrames.insert(index)
        }
    }
}

struct RoundedRectangleView: View {

    @ObservedObject var zoomScale: ZoomScale

    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3

    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: currentCornerRadius)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: currentCornerRadius)
                    .strokeBorder(isSelected ? .yellow : .secondary, lineWidth: isSelected ? currentLineWidth : 1)
            )
            .animation(.smooth(duration: 0.3), value: zoomScale.scale)
            .onTapGesture {
                withAnimation(.smooth(duration: 0.3)) { onTap() }
            }
    }

    private var currentCornerRadius: CGFloat {
        let minScale: CGFloat = 0.3
        let maxScale: CGFloat = 1.0
        let normalizedScale = (zoomScale.scale - minScale) / (maxScale - minScale)
        let invertedScale = 1 - normalizedScale
        let cornerRadius = invertedScale * maxCornerRadius

        return cornerRadius
    }

    private var currentLineWidth: CGFloat {
        let minScale: CGFloat = 0.3
        let maxScale: CGFloat = 1.0
        let clampedScale = max(minScale, min(zoomScale.scale, maxScale))
        let m: CGFloat = -2.86
        let b: CGFloat = 3.86
        let lineWidth = m * clampedScale + b

        return lineWidth
    }
}


struct ZoomAndPanView<Content: View>: UIViewRepresentable {

    @ObservedObject var zoomScale: ZoomScale
    @ObservedObject var pageModel: PageModel

    let frameWidth: CGFloat
    let totalFrames: CGFloat
    let frameSpacing: CGFloat
    var content: Content

    init(totalFrames: CGFloat, frameSpacing: CGFloat, zoomScale: ZoomScale, pageModel: PageModel, @ViewBuilder content: () -> Content) {
        self.totalFrames = totalFrames
        self.frameSpacing = frameSpacing
        self.zoomScale = zoomScale
        self.pageModel = pageModel
        self.content = content()
        self.frameWidth = UIScreen.main.bounds.width
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(zoomScale: zoomScale, frameWidth: frameWidth, totalFrames: totalFrames, frameSpacing: frameSpacing, pageModel: pageModel)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingView: UIView!
        var zoomScale: ZoomScale
        var frameWidth: CGFloat
        var totalFrames: CGFloat
        var frameSpacing: CGFloat
        var pageModel: PageModel // New property for page tracking

        init(zoomScale: ZoomScale, frameWidth: CGFloat, totalFrames: CGFloat, frameSpacing: CGFloat, pageModel: PageModel) {
            self.zoomScale = zoomScale
            self.frameWidth = frameWidth
            self.totalFrames = totalFrames
            self.frameSpacing = frameSpacing
            self.pageModel = pageModel // Initialize pageModel
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            scrollView.contentOffset.y = 0
            centerScrollViewContents(scrollView)
            zoomScale.scale = scrollView.zoomScale
            scrollView.isPagingEnabled = false
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.contentOffset.y = 0
        }

        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard scrollView.zoomScale == 1 else {
                // Ignore the rest of the function and return early if zoomScale is not 1.
                return
            }

            // Your custom page width
            let pageWidth = frameWidth + frameSpacing

            // Calculate which page to scroll to
            let approximatePage = scrollView.contentOffset.x / pageWidth
            let nextPage: CGFloat
            if velocity.x == 0 {
                nextPage = round(approximatePage)
            } else {
                nextPage = velocity.x > 0 ? ceil(approximatePage) : floor(approximatePage)
            }

            // Calculate new content offset
            var pointX = nextPage * pageWidth

            // Ensure that pointX is within the allowable range
            pointX = max(0, min(pointX, scrollView.contentSize.width - scrollView.frame.width))

            targetContentOffset.pointee = CGPoint(x: pointX, y: targetContentOffset.pointee.y)

            UIView.animate(
                withDuration: 0.39, // Duration of the animation
                delay: 0, // Delay before the animation starts
                usingSpringWithDamping: 1, // Controls "bounciness" - 0 is very bouncy, 1 is no bounce
                initialSpringVelocity: 0.1, // Controls the initial velocity of the animation
                options: [.curveEaseOut, .allowUserInteraction], // Enable user interactions during animation
                animations: {
                    scrollView.contentOffset = CGPoint(x: pointX, y: 0)
                }
            )
        }

        func centerScrollViewContents(_ scrollView: UIScrollView) {
            let boundsSize = scrollView.bounds.size
            var contentsFrame = hostingView.frame

            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            } else {
                contentsFrame.origin.x = 0.0
            }

            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            } else {
                contentsFrame.origin.y = 0.0
            }

            hostingView.frame = contentsFrame
        }

        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            let scrollView = recognizer.view as! UIScrollView

            if scrollView.zoomScale == 1.0 {
                scrollView.setZoomScale(0.3, animated: true)
            } else {
                scrollView.setZoomScale(1.0, animated: true)
            }
        }
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0.3
        scrollView.maximumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.isPagingEnabled = false

        let containerView = UIView()
        containerView.frame = CGRect(
            x: 0,
            y: UIScreen.main.bounds.midY - 110,
            width: (frameWidth + frameSpacing) * totalFrames - frameSpacing,
            height: frameWidth * (9/16)
        )

        let hostView = UIHostingController(rootView: content)
        hostView.view.frame = containerView.bounds
        hostView.view.backgroundColor = .clear

        containerView.addSubview(hostView.view)
        scrollView.addSubview(containerView)
        scrollView.contentSize = containerView.frame.size

        context.coordinator.hostingView = containerView

        let doubleTapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let hostView = UIHostingController(rootView: content)

        hostView.view.frame = context.coordinator.hostingView.bounds
        hostView.view.backgroundColor = .clear

        context.coordinator.hostingView.subviews.forEach { $0.removeFromSuperview() }
        context.coordinator.hostingView.addSubview(hostView.view)
    }
}
