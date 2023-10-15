//
//  AudioTimeline.swift
//  FilmFX
//
//  Created by Paul Wong on 10/14/23.
//

import SwiftUI

struct AudioTimeline: View {

    @ObservedObject var pageModel: PageModel
    @ObservedObject var gestureManager: GestureManager
    @ObservedObject var dragState: DragState
    @ObservedObject var selectionManager: TimelineSelectionManager

    var frameSpacing: CGFloat

    @Binding var selectedFrames: Set<Int>
    @Binding var editStrength: Bool

    let frameWidth: CGFloat = UIScreen.main.bounds.maxX
    let totalFrames: Int = 20
    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 1.0

    let sections: [TimelineSection] = [
        TimelineSection(icon: "waveform", text: "*Luna.wav", length: 5, frameOffset: 0),
        TimelineSection(icon: "music.note", text: "メタフィクション.wav", length: 2, frameOffset: 0),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(sections.indices, id: \.self) { index in
                Button(action: {
                    Haptics.shared.play(.light)
                    onTapSection(index: index)
                    selectedFrames.removeAll()
                    withAnimation(.smooth(duration: 0.3)) { pageModel.showTip = false }
                }) {
                    HStack(spacing: 0) {
                        Image(systemName: "chevron.compact.left")

                        HStack(spacing: 7) {
                            Image(systemName: sections[index].icon)
                                .font(.system(size: UIConstants.callout).weight(.medium))
                                .symbolRenderingMode(.hierarchical)
                                .frame(height: 17)

                            Group {
                                Text(sections[index].text + " • ")
                                    .foregroundColor(.black)
                                + Text("100")
                                    .foregroundColor(.black.opacity(0.5))
                            }
                            .font(.custom("SFCamera", size: UIConstants.callout))
                            .tracking(0.3)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .offset(x: gestureManager.offsetX > 26 + ((frameSpacing + currentWidth) * sections[index].frameOffset) ? gestureManager.offsetX - 26 - ((frameSpacing + currentWidth) * sections[index].frameOffset) : 0)
                        .background(.black.opacity(0.3))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 4)
                        )
                        .padding(.horizontal, 7)

                        Image(systemName: "chevron.compact.right")
                    }
                    .foregroundColor(.black)
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        ZStack {
                            Color.white
                            Color.pink.opacity(0.9)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .frame(width: (currentWidth * sections[index].length) + (frameSpacing * (sections[index].length - 1)) - frameSpacing/2)
                    .opacity(selectionManager.selectedSectionIndex == index ? 1.0 : 0.39)
                    .offset(x: (frameSpacing + currentWidth) * sections[index].frameOffset)
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
        .offset(y: currentOffset)
        .offset(x: -gestureManager.offsetX)
        .animation(.smooth(duration: 0.3), value: ((abs(gestureManager.offsetX)/gestureManager.page) - 9).truncatingRemainder(dividingBy: UIScreen.main.bounds.maxX) == 0)
        .animation(.smooth(duration: 0.3), value: gestureManager.offsetX != 0)
        .animation(.smooth(duration: 0.3), value: gestureManager.scale != 0.3)
        .animation(.smooth(duration: 0.3), value: gestureManager.scale != 1)
    }

    private func onTapSection(index: Int) {
        withAnimation(.smooth(duration: 0.3)) {
            editStrength = false
        }

        if selectionManager.selectedSectionIndex == index {
            // Deselect the section if it's tapped when already selected
            selectionManager.selectedSectionIndex = nil
        } else {
            // Otherwise, select the tapped section
            selectionManager.selectedSectionIndex = index
        }
    }

    private func isSelected(index: Int) -> Bool {
        // If no section is selected, treat all as selected
        guard let selectedSectionIndex = selectionManager.selectedSectionIndex else {
            return true
        }
        // Otherwise, only the selected section is treated as selected
        return index == selectedSectionIndex
    }

    func interpolatedValue(for scale: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
        let clampedScale = gestureManager.scale
        let normalizedScale = (clampedScale - minScale) / (maxScale - minScale)
        return minVal + normalizedScale * (maxVal - minVal)
    }

    var currentOffset: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 0, maxVal: 80)
    }

    var currentWidth: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: frameWidth * minScale, maxVal: frameWidth)
    }
}
