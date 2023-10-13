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

class GestureManager: ObservableObject {
    @Published var scale: CGFloat = 1.0
    @Published var offsetX: CGFloat = 0
    @Published var page: CGFloat = 0
}

class DragState: ObservableObject {
    @Published var isDragging: Bool = false
}

class TimelineSelectionManager: ObservableObject {
    @Published var selectedSectionIndex: Int? = nil
}

class ScrollManager: ObservableObject {
    @Published var positionID: Int = 0
}

struct ViewFinder: View {

    @Environment(\.safeAreaInsets) var safeAreaInsets

    @StateObject private var gestureManager = GestureManager()
    @StateObject private var pageModel = PageModel()
    @StateObject private var dragState = DragState()
    @StateObject private var selectionManager = TimelineSelectionManager()
    @StateObject private var scrollManager = ScrollManager()

    let frameWidth: CGFloat = UIScreen.main.bounds.maxX
    let totalFrames: Int = 20
    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 1.0
    let frameSpacing: CGFloat = 9

    @State var selectedFrames = Set<Int>()
    @State var gestureOffsetX: CGFloat = 0.0
    @State var lastGestureOffsetX: CGFloat = 0.0

    var body: some View {
        ZoomAndPanView(totalFrames: CGFloat(totalFrames), frameSpacing: frameSpacing, gestureManager: gestureManager, pageModel: pageModel, dragState: dragState) {
            HStack(alignment: .top, spacing: frameSpacing) {
                ForEach(0..<totalFrames, id: \.self) { index in
                    FrameRectangle(gestureManager: gestureManager, number: index + 1, frameWidth: frameWidth, isSelected: selectedFrames.contains(index)) {
                        handleTap(for: index)
                    }
                }
            }
        }
        .offset(y: -50)
        .ignoresSafeArea(.container)
        .background(.black)
        .overlay(
            Timeline(gestureManager: gestureManager, dragState: dragState, selectionManager: selectionManager, frameSpacing: frameSpacing)
                .offset(y: 390)
            , alignment: .topLeading
        )
        .overlay(
            Group {
                if selectionManager.selectedSectionIndex != nil {
                    ZStack(alignment: .bottom) {
                        VStack(spacing: 5) {
                            Text(String(scrollManager.positionID))
                                .font(.system(.subheadline, design: .monospaced).weight(.medium))
                                .foregroundColor(scrollManager.positionID == 0 ? .white : .yellow)

                            Capsule()
                                .fill(scrollManager.positionID == 0 ? .white : .yellow)
                                .frame(width: 1, height: 25)
                        }
                        .offset(y: -40)

                        ScrollViewWrapper(scrollManager: scrollManager) {
                            HStack(spacing: 9) {
                                ForEach(0..<4, id: \.self) { _ in
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: 1, height: 11)
                                    ForEach(0..<9, id: \.self) { _ in
                                        Capsule()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 1, height: 10)
                                    }
                                }
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 1, height: 12)
                            }
                        }
                        .frame(height: 92)
                    }
                }
            }
            , alignment: .bottom
        )
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
                        .font(.system(.subheadline, design: .monospaced).weight(.medium))
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
