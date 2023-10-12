//
//  ViewFinder.swift
//  FilmFX
//
//  Created by Paul Wong on 10/11/23.
//

import SwiftUI

class PageModel: ObservableObject {
    @Published var currentPage: Int = 0
}

class ZoomScale: ObservableObject {
    @Published var scale: CGFloat = 1.0
}

class DragState: ObservableObject {
    @Published var isDragging: Bool = false
}

struct ViewFinder: View {

    @Environment(\.safeAreaInsets) var safeAreaInsets

    @StateObject private var zoomScale = ZoomScale()
    @StateObject private var pageModel = PageModel()
    @StateObject private var dragState = DragState()

    let frameWidth: CGFloat = UIScreen.main.bounds.maxX
    let totalFrames: Int = 50
    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 1.0
    let frameSpacing: CGFloat = 9

    @State var selectedFrames = Set<Int>()

    var body: some View {
        ZoomAndPanView(totalFrames: CGFloat(totalFrames), frameSpacing: frameSpacing, zoomScale: zoomScale, pageModel: pageModel, dragState: dragState) {
            LazyHStack(alignment: .top, spacing: frameSpacing) {
                ForEach(0..<totalFrames, id: \.self) { index in
                    FrameRectangle(zoomScale: zoomScale, number: index + 1, frameWidth: frameWidth, isSelected: selectedFrames.contains(index)) {
                        handleTap(for: index)
                    }
                }
            }
            .offset(y: -40)
        }
        .ignoresSafeArea(.container)
        .background(.black)
        .overlay(
            VStack(spacing: 9) {
                if selectedFrames.count > 0 {
                    Text("^[\(selectedFrames.count) FRAME](inflect: true) SELECTED")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.black)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 7)
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }

                if dragState.isDragging {
                    Text("00:10.39")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 7)
                        .background(.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            .padding(16)
            .animation(.smooth(duration: 0.3), value: dragState.isDragging)
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
