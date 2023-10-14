//
//  ViewFinder.swift
//  FilmFX
//
//  Created by Paul Wong on 10/11/23.
//

import SwiftUI

struct ViewFinder: View {

    @Environment(\.safeAreaInsets) var safeAreaInsets

    @State var gestureManager = GestureManager()
    @State var pageModel = PageModel()
    @State var dragState = DragState()
    @State var selectionManager = TimelineSelectionManager()
    @State var scrollManager = ScrollManager()

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
    @State var editStrength = false

    var body: some View {
        ZoomAndPanView(totalFrames: CGFloat(totalFrames), frameSpacing: frameSpacing, gestureManager: gestureManager, pageModel: pageModel, dragState: dragState) {
            LazyHStack(alignment: .top, spacing: frameSpacing) {
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
            Timeline(gestureManager: gestureManager, dragState: dragState, selectionManager: selectionManager, frameSpacing: frameSpacing, selectedFrames: $selectedFrames)
                .offset(y: 390)
            , alignment: .topLeading
        )
        .overlay(
            Group {
                if selectionManager.selectedSectionIndex != nil {
                    if !editStrength {
                        HStack(alignment: .top) {
                            Spacer()
                            Button(action: { withAnimation(.smooth(duration: 0.3)) { editStrength = true } }) {
                                VStack(spacing: 2) {
                                    Text("Strength".uppercased())
                                        .font(.custom("SFCamera", size: UIConstants.subheadline))

                                    Text("9")
                                        .font(.custom("SFCamera", size: UIConstants.subheadline))
                                        .padding(.bottom, 3)

                                    HStack(alignment: .bottom, spacing: 7) {
                                        ForEach(0..<7, id: \.self) { index in
                                            Capsule()
                                                .fill(.gray.opacity(0.65))
                                                .frame(width: 1, height: (index % 3 == 0) ? 9 : 6)
                                        }
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(DefaultButtonStyle())
                            Spacer()
                            VStack(spacing: 7) {
                                Text("Edit".uppercased())
                                    .font(.custom("SFCamera", size: UIConstants.subheadline))

                                Image(systemName: "character.cursor.ibeam")
                                    .font(.system(size: UIConstants.footnote))
                                    .frame(height: 14)
                            }
                            Spacer()
                            VStack(spacing: 7) {
                                Text("Duplicate".uppercased())
                                    .font(.custom("SFCamera", size: UIConstants.subheadline))

                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: UIConstants.footnote))
                                    .frame(height: 14)
                            }
                            Spacer()
                            VStack(spacing: 7) {
                                Text("Delete".uppercased())
                                    .font(.custom("SFCamera", size: UIConstants.subheadline))

                                Image(systemName: "delete.backward")
                                    .font(.system(size: UIConstants.footnote))
                                    .frame(height: 14)
                            }
                            .foregroundColor(.red)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                    } else {
                        ZStack(alignment: .bottom) {
                            VStack(spacing: 7) {
                                Text(String(min(50, max(-50, scrollManager.positionID))))
                                    .font(.custom("SFCamera", size: UIConstants.callout))
                                    .tracking(1)
                                    .foregroundColor(scrollManager.positionID == 0 ? .white : .yellow)

                                Capsule()
                                    .fill(scrollManager.positionID == 0 ? .white : .yellow)
                                    .frame(width: 1, height: 25)
                            }
                            .offset(y: -30)

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
                                        .frame(width: 1, height: 11)
                                }
                                .overlay(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 5, height: 5)
                                        .offset(y: 15)
                                    , alignment: .bottom
                                )
                            }
                            .frame(height: 72)
                            .contentShape(Rectangle())
                            .mask(LinearGradient(gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.15),
                                .init(color: .black, location: 0.85),
                                .init(color: .clear, location: 1)
                            ]), startPoint: .leading, endPoint: .trailing))
                        }
                        .overlay(
                            Button(action: { withAnimation(.smooth(duration: 0.3)) { editStrength = false } }) {
                                Text("Strength".uppercased())
                                    .font(.custom("SFCamera", size: UIConstants.subheadline))
                                    .foregroundColor(scrollManager.positionID == 0 ? .white : .yellow)
                                    .offset(y: -8)
                                    .padding(.trailing, 16)
                                    .padding(20)
                                    .contentShape(Rectangle())
                            }
                            .padding(-20)
                            .buttonStyle(DefaultButtonStyle())
                            , alignment: .topTrailing
                        )
                    }
                } else {
                    Text("Select frames to add effects")
                        .font(.custom("SFCamera", size: UIConstants.subheadline))
                        .foregroundColor(.white)
                        .padding(.bottom, 3)
                }
            }
            .animation(.smooth(duration: 0.3), value: selectionManager.selectedSectionIndex)
            , alignment: .bottom
        )
        .overlay(
            VStack(spacing: 9) {
                HStack {
                    Spacer()
                    Text("Untitled Video")
                        .font(.custom("SFCamera", size: UIConstants.body))
                        .foregroundColor(.white)
                    Spacer()
                }
                .overlay(
                    Group {
                        if selectionManager.selectedSectionIndex != nil || selectedFrames.count > 0 {
                            Button(action: {
                                withAnimation(.smooth(duration: 0.3)) {
                                    selectionManager.selectedSectionIndex = nil
                                    selectedFrames.removeAll()
                                }
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: UIConstants.subheadline).weight(.medium))
                                    .foregroundStyle(.black)
                                    .padding(.vertical, 9)
                                    .padding(.horizontal, 26)
                                    .background(.yellow)
                                    .clipShape(RoundedRectangle(cornerRadius: 39, style: .continuous))
                            }
                            .buttonStyle(DefaultButtonStyle())
                        }
                    }
                    .animation(.smooth(duration: 0.3), value: selectionManager.selectedSectionIndex)
                    , alignment: .trailing
                )
                .padding(.bottom, 5)

                if selectedFrames.count > 0 {
                    Text("^[\(selectedFrames.count) FRAME](inflect: true) SELECTED")
                        .font(.custom("SFCamera", size: UIConstants.subheadline))
                        .foregroundColor(.black)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 7)
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }

                if dragState.isDragging {
                    Text(timeString(from: gestureManager.offsetX))
                        .font(.custom("SFCamera", size: UIConstants.callout))
                        .tracking(1)
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

    func handleTap(for index: Int) {
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

        selectionManager.selectedSectionIndex = nil
    }

    func timeString(from offsetX: CGFloat) -> String {
        // Considering the max offsetX value is UIScreen.main.bounds.maxX * 20 and maps to 10 seconds
        let totalFrames = min(max(0, Int(gestureManager.offsetX / currentWidth * 300)), 300) // 10s * 30f

        let seconds = totalFrames / 30
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        let frames = totalFrames % 30

        return String(format: "%02d:%02d.%02d", minutes, remainingSeconds, frames)
    }

    func interpolatedValue(for scale: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
        let clampedScale = gestureManager.scale
        let normalizedScale = (clampedScale - minScale) / (maxScale - minScale)
        return minVal + normalizedScale * (maxVal - minVal)
    }

    var currentWidth: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: (frameWidth * CGFloat(totalFrames)) * (3/10), maxVal: frameWidth * CGFloat(totalFrames))
    }
}
