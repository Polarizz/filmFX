//
//  Timeline.swift
//  FilmFX
//
//  Created by Paul Wong on 10/12/23.
//

import SwiftUI

struct TimelineSection {
    var icon: String
    var text: String
    var length: CGFloat
    var frameOffset: CGFloat
}

struct Timeline: View {

    @ObservedObject var gestureManager: GestureManager
    @ObservedObject var dragState: DragState
    @ObservedObject var selectionManager: TimelineSelectionManager

    var frameSpacing: CGFloat

    let frameWidth: CGFloat = UIScreen.main.bounds.maxX
    let totalFrames: Int = 20
    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 1.0

    let sections: [TimelineSection] = [
        TimelineSection(icon: "circle.dotted.circle", text: "Vignette", length: 2, frameOffset: 0),
        TimelineSection(icon: "plusminus.circle", text: "Exposure", length: 3, frameOffset: 0),
        TimelineSection(icon: "circle.righthalf.filled", text: "Contrast", length: 2, frameOffset: 1),
        TimelineSection(icon: "thermometer.medium", text: "Temperature", length: 5, frameOffset: 2)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(sections.indices, id: \.self) { index in
                Button(action: {
                    Haptics.shared.play(.light)
                    onTapSection(index: index)
                }) {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(.yellow)
                        .frame(width: (currentWidth * sections[index].length) + (frameSpacing * (sections[index].length - 1)) - frameSpacing/2, height: 43)
                        .overlay(
                            HStack(spacing: 0) {
                                Image(systemName: "chevron.compact.left")

                                HStack(spacing: 7) {
                                    Image(systemName: sections[index].icon)
                                        .font(.callout.weight(.medium))
                                        .symbolRenderingMode(.hierarchical)

                                    Text(sections[index].text)
                                        .font(.custom("SFCamera", size: UIConstants.callout))
                                        .tracking(0.3)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 9)
                                .offset(x: gestureManager.offsetX > 26 + ((frameSpacing + currentWidth) * sections[index].frameOffset) ? gestureManager.offsetX - 26 - ((frameSpacing + currentWidth) * sections[index].frameOffset) : 0)
                                .background(.black.opacity(0.39))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 4)
                                )
                                .padding(.horizontal, 7)

                                Image(systemName: "chevron.compact.right")
                            }
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 7)
                        )
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
        let invertedScale = 1 - normalizedScale
        return minVal + normalizedScale * (maxVal - minVal)
    }

    var currentOffset: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 0, maxVal: 80)
    }

    var currentWidth: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: frameWidth * minScale, maxVal: frameWidth)
    }
}
