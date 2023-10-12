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

    var body: some View {
        ZoomAndPanView(totalFrames: CGFloat(totalFrames), frameSpacing: frameSpacing, zoomScale: zoomScale, pageModel: pageModel) {
            HStack(spacing: frameSpacing) {
                ForEach(0..<totalFrames) { _ in
                    RoundedRectangleView(zoomScale: zoomScale)
                        .frame(width: frameWidth, height: frameWidth * (9/16))
                }
            }
            .offset(y: -40)
        }
        .ignoresSafeArea(.container)
        .background(.black)
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
                withDuration: 0.3, // Duration of the animation
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
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0.39
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

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}
}

struct RoundedRectangleView: View {

    @ObservedObject var zoomScale: ZoomScale

    @State var selected = false

    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3

    var body: some View {
        RoundedRectangle(cornerRadius: currentCornerRadius)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: currentCornerRadius)
                    .strokeBorder(selected ? .yellow : .secondary, lineWidth: selected ? currentLineWidth : 1)
            )
            .animation(.smooth(duration: 0.3), value: zoomScale.scale)
            .onTapGesture {
                withAnimation(.smooth(duration: 0.3)) {
                    selected.toggle()
                }
            }
    }

    private var currentCornerRadius: CGFloat {
        let minScale: CGFloat = 0.39
        let maxScale: CGFloat = 1.0

        let normalizedScale = (zoomScale.scale - minScale) / (maxScale - minScale)
        let invertedScale = 1 - normalizedScale
        let cornerRadius = invertedScale * maxCornerRadius

        return cornerRadius
    }

    private var currentLineWidth: CGFloat {
        let minScale: CGFloat = 0.39
        let maxScale: CGFloat = 1.0

        // Assuming zoomScale.scale is defined and is in the range [minScale, maxScale]
        // Clamp the value to be sure it's within the expected range.
        let clampedScale = max(minScale, min(zoomScale.scale, maxScale))

        // Coefficients derived from the two points provided (zoomScale.scale, lineWidth): (1, 1) and (0.39, 3)
        let m: CGFloat = -3.28
        let b: CGFloat = 4.28

        let lineWidth = m * clampedScale + b

        return lineWidth
    }
}
