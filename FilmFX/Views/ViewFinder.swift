//
//  ViewFinder.swift
//  FilmFX
//
//  Created by Paul Wong on 10/11/23.
//

import SwiftUI

struct ViewFinder: View {

    @Environment(\.safeAreaInsets) var safeAreaInsets

    @GestureState var gestureOffsetY: CGFloat = 0.0
    @State var fakeOffsetY: CGFloat = 0.0

    @State var gestureManager = GestureManager()
    @State var pageModel = PageModel()
    @State var dragState = DragState()
    @State var selectionManager = TimelineSelectionManager()
    @State var scrollManager = ScrollManager()
    @State var cm = ControlsManager()

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
    @State var showMoreControls = false

    var body: some View {
        ZoomAndPanView(totalFrames: CGFloat(totalFrames), frameSpacing: frameSpacing, gestureManager: gestureManager, pageModel: pageModel, dragState: dragState) {
            LazyHStack(alignment: .top, spacing: frameSpacing) {
                ForEach(0..<totalFrames, id: \.self) { index in
                    FrameRectangle(gestureManager: gestureManager, number: index + 1, frameWidth: frameWidth, isSelected: selectedFrames.contains(index), editStrength: $editStrength) {
                        handleTap(for: index)
                    }
                }
            }
        }
        .offset(y: -60)
        .background(.black)
        .overlay(
            Group {
                if !cm.showAudio {
                    Timeline(pageModel: pageModel, gestureManager: gestureManager, dragState: dragState, selectionManager: selectionManager, frameSpacing: frameSpacing, selectedFrames: $selectedFrames, editStrength: $editStrength)
                        .offset(y: currentOffset)
                        .transition(.move(edge: .top))
                }
            }
            .opacity(cm.showAudio ? 0 : 1)
            .blur(radius: cm.showAudio ? 30 : 0)
            .animation(.smooth(duration: 0.39), value: cm.showAudio)
            , alignment: .topLeading
        )
        .overlay(
            Group {
                if cm.showAudio {
                    AudioTimeline(pageModel: pageModel, gestureManager: gestureManager, dragState: dragState, selectionManager: selectionManager, frameSpacing: frameSpacing, selectedFrames: $selectedFrames, editStrength: $editStrength)
                        .offset(y: currentOffset)
                        .transition(.move(edge: .bottom))
                }
            }
                .opacity(!cm.showAudio ? 0 : 1)
            .blur(radius: !cm.showAudio ? 30 : 0)
            .animation(.smooth(duration: 0.39), value: cm.showAudio)
            , alignment: .topLeading
        )
        .offset(y: gestureOffsetY)
        .simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .updating($gestureOffsetY) { value, state, _ in
                    state = (value.translation.height > 0 ? sqrt(value.translation.height) : -sqrt(-value.translation.height)) * 11
                }
                .onChanged { value in
                    fakeOffsetY = (value.translation.height > 0 ? sqrt(value.translation.height) : -sqrt(-value.translation.height)) * 11
                    if fakeOffsetY < -120  {
                        cm.showAudio = true
                        selectedFrames.removeAll()
                        editStrength = false
                        selectionManager.selectedSectionIndex = nil
                    }

                    if fakeOffsetY > 120 {
                        cm.showAudio = false
                    }

//                    if cm.showAudio = false && fakeOffsetY > 120 {
//
//                    }
                }
        )
        .onChange(of: cm.showAudio) {
            Haptics.shared.play(.light)
        }
        .animation(.smooth(duration: 0.39), value: gestureOffsetY != 0)
        .animation(.smooth(duration: 0.2), value: gestureOffsetY)

        .overlay(
            VStack {
                SafeAreaBlockTop()
                Spacer()
                SafeAreaBlockBottom()
            }
            .ignoresSafeArea(.container)
            , alignment: .bottom
        )
        .overlay(
            ZStack(alignment: .center) {
                Group {
                    if selectedFrames.count == 0 && selectionManager.selectedSectionIndex == nil && !showMoreControls {
                        playbackControls
                            .transition(.move(edge: .top))
                    }
                }
                .opacity(selectedFrames.count == 0 && selectionManager.selectedSectionIndex == nil && !showMoreControls ? 1 : 0)
                .blur(radius: selectedFrames.count == 0 && selectionManager.selectedSectionIndex == nil && !showMoreControls ? 0 : 20)

                Group {
                    if selectedFrames.count != 0 && !showMoreControls {
                        newEffectControl
                            .transition(.move(edge: .bottom))
                    }
                }
                .opacity(selectedFrames.count != 0 && !showMoreControls ? 1 : 0)
                .blur(radius: selectedFrames.count != 0 && !showMoreControls ? 0 : 20)

                Group {
                    if selectionManager.selectedSectionIndex != nil && !editStrength && !showMoreControls {
                        effectControls
                    }
                }
                .offset(y: selectionManager.selectedSectionIndex != nil ? 0 : 20)
                .blur(radius: selectionManager.selectedSectionIndex != nil && !editStrength && !showMoreControls ? 0 : 10)
                .offset(y: editStrength && !showMoreControls ? -20 : 0)

                Group {
                    if editStrength && selectedFrames.count == 0 && !showMoreControls {
                        strengthControl
                    }
                }
                .offset(y: editStrength && selectedFrames.count == 0 && !showMoreControls ? 0 : 40)
                .blur(radius: editStrength && selectedFrames.count == 0 && !showMoreControls ? 0 : 10)

                Group {
                    if showMoreControls {
                        moreControls
                            .transition(.move(edge: .bottom))
                    }
                }
                .opacity(showMoreControls ? 1 : 0)
                .blur(radius: showMoreControls ? 0 : 10)
            }
            .padding(.bottom, 70)
            .animation(.smooth(duration: 0.3), value: selectionManager.selectedSectionIndex)
            , alignment: .bottom
        )
        .overlay(
            ZStack {
                Text("Select frames to add effects")
                    .font(.custom("SFCamera", size: UIConstants.subheadline))
                    .foregroundColor(.white)
                    .opacity(pageModel.showTip ? 1 : 0)

                Button(action: {
                    withAnimation(.smooth(duration: 0.3)) {
                        showMoreControls.toggle()
                    }
                }) {
                    Image(systemName: showMoreControls ? "chevron.down" : "chevron.up")
                        .font(.system(size: UIConstants.body).weight(.medium))
                        .foregroundColor(.white)
                        .offset(y: showMoreControls ? 1 : -1)
                        .padding(11)
                        .background(.gray.opacity(0.2))
                        .clipShape(Circle())
                        .opacity(!pageModel.showTip ? 1 : 0)
                        .contentShape(Rectangle())
                }
                .buttonStyle(DefaultButtonStyle())
            }
            .padding(.bottom, 3)
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

    var effectControls: some View {
        HStack(alignment: .top) {
            Spacer()
            Button(action: { withAnimation(.smooth(duration: 0.3)) { editStrength = true } }) {
                VStack(spacing: 2) {
                    Text((cm.showAudio ? "Volume" : "Strength").uppercased())
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
            VStack(spacing: 9) {
                Text("Edit".uppercased())
                    .font(.custom("SFCamera", size: UIConstants.subheadline))

                Image(systemName: "character.cursor.ibeam")
                    .font(.system(size: UIConstants.footnote))
                    .frame(height: 14)
            }
            Spacer()
            VStack(spacing: 9) {
                Text("Duplicate".uppercased())
                    .font(.custom("SFCamera", size: UIConstants.subheadline))

                Image(systemName: "doc.on.doc")
                    .font(.system(size: UIConstants.footnote))
                    .frame(height: 14)
            }
            Spacer()
            VStack(spacing: 9) {
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
        .offset(y: 7)
    }

    var moreControls: some View {
        HStack(alignment: .top) {
            Spacer()
            Button(action: { withAnimation(.smooth(duration: 0.3)) { cm.showEdits.toggle() } }) {
                VStack(spacing: 9) {
                    Text("Edits".uppercased())
                        .font(.custom("SFCamera", size: UIConstants.subheadline))

                    Image(systemName: cm.showEdits ? "eye" : "eye.slash")
                        .font(.system(size: UIConstants.footnote))
                        .frame(height: 14)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(DefaultButtonStyle())
            Spacer()
            Button(action: { withAnimation(.smooth(duration: 0.3)) { cm.showGrid.toggle() } }) {
                VStack(spacing: 9) {
                    Text("Grid".uppercased())
                        .font(.custom("SFCamera", size: UIConstants.subheadline))

                    Image(systemName: cm.showGrid ? "squareshape.split.3x3" : "square")
                        .font(.system(size: UIConstants.subheadline))
                        .frame(height: 15)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(DefaultButtonStyle())
            Spacer()
            Button(action: { withAnimation(.smooth(duration: 0.3)) { cm.showAudio.toggle() } }) {
                VStack(spacing: 9) {
                    Text((cm.showAudio ? "Audio" : "Video").uppercased())
                        .font(.custom("SFCamera", size: UIConstants.subheadline))

                    Image(systemName: cm.showAudio ? "music.note" : "play.rectangle")
                        .font(.system(size: UIConstants.footnote))
                        .frame(height: 14)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(DefaultButtonStyle())
            Spacer()
        }
        .foregroundColor(.white)
        .offset(y: -3)
    }

    var strengthControl: some View {
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
                Text((cm.showAudio ? "Volume" : "Strength").uppercased())
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
        .offset(y: 35)
    }

    var playbackControls: some View {
        HStack(spacing: 60) {
            Button(action: { }) {
                Image(systemName: "backward.frame.fill")
                    .font(.system(size: UIConstants.title))
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlayButtonStyle())

            Button(action: { }) {
                Image(systemName: "play.fill")
                    .font(.system(size: UIConstants.largeTitle))
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlayButtonStyle())

            Button(action: { }) {
                Image(systemName: "forward.frame.fill")
                    .font(.system(size: UIConstants.title))
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlayButtonStyle())
        }
        .foregroundColor(.white.opacity(0.9))
    }

    var newEffectControl: some View {
        HStack(spacing: 0) {
            HStack(spacing: 7) {
                Image(systemName: "character.cursor.ibeam")
                    .font(.system(size: UIConstants.callout).weight(.medium))
                    .symbolRenderingMode(.hierarchical)
                    .frame(height: 17)

                Group {
                    Text("Effect")
                }
                .font(.custom("SFCamera", size: UIConstants.callout))
                .tracking(0.3)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(10)
            .background(.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .padding(.trailing, 10)

            Image(systemName: "plus.circle.fill")
        }
        .foregroundColor(.white)
        .font(.title3.weight(.semibold))
        .padding(.trailing, 10)
        .padding([.vertical, .leading], 3)
        .background(.gray.opacity(0.39))
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .padding(.horizontal, 16)
        .offset(y: 5)
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

        withAnimation(.smooth(duration: 0.3)) { pageModel.showTip = false }
        cm.showAudio = false
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

    var currentOffset: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 380, maxVal: 385)
    }
}
