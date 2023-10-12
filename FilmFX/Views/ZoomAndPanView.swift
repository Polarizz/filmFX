//
//  ZoomAndPanView.swift
//  FilmFX
//
//  Created by Paul Wong on 10/12/23.
//

import SwiftUI
import UIKit

struct ZoomAndPanView<Content: View>: UIViewRepresentable {

    @ObservedObject var zoomScale: ZoomScale
    @ObservedObject var pageModel: PageModel
    @ObservedObject var dragState: DragState

    let frameWidth: CGFloat
    let totalFrames: CGFloat
    let frameSpacing: CGFloat
    var content: Content

    init(totalFrames: CGFloat, frameSpacing: CGFloat, zoomScale: ZoomScale, pageModel: PageModel, dragState: DragState, @ViewBuilder content: () -> Content) {
        self.totalFrames = totalFrames
        self.frameSpacing = frameSpacing
        self.zoomScale = zoomScale
        self.pageModel = pageModel
        self.dragState = dragState
        self.content = content()
        self.frameWidth = UIScreen.main.bounds.width
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(zoomScale: zoomScale, frameWidth: frameWidth, totalFrames: totalFrames, frameSpacing: frameSpacing, pageModel: pageModel, dragState: dragState)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingView: UIView!
        var zoomScale: ZoomScale
        var frameWidth: CGFloat
        var totalFrames: CGFloat
        var frameSpacing: CGFloat
        var pageModel: PageModel
        var dragState: DragState

        init(zoomScale: ZoomScale, frameWidth: CGFloat, totalFrames: CGFloat, frameSpacing: CGFloat, pageModel: PageModel, dragState: DragState) {
            self.zoomScale = zoomScale
            self.frameWidth = frameWidth
            self.totalFrames = totalFrames
            self.frameSpacing = frameSpacing
            self.pageModel = pageModel
            self.dragState = dragState
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
            guard scrollView.zoomScale == 1 else { return }

            let pageWidth = frameWidth + frameSpacing
            let approximatePage = scrollView.contentOffset.x / pageWidth
            let nextPage: CGFloat

            if velocity.x == 0 {
                nextPage = round(approximatePage)
            } else {
                nextPage = velocity.x > 0 ? ceil(approximatePage) : floor(approximatePage)
            }

            var pointX = nextPage * pageWidth

            pointX = max(0, min(pointX, scrollView.contentSize.width - scrollView.frame.width))

            targetContentOffset.pointee = CGPoint(x: pointX, y: targetContentOffset.pointee.y)

            UIView.animate(
                withDuration: 0.39,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.1,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: {
                    scrollView.contentOffset = CGPoint(x: pointX, y: 0)
                }
            )
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            dragState.isDragging = true
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.dragState.isDragging = false
            }
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
