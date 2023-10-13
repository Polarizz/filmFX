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

    @State private var selectedSectionIndex: Int? = nil  // Keep track of the selected section

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
        TimelineSection(icon: "thermometer.medium", text: "Temperature", length: 5, frameOffset: 2),
        TimelineSection(icon: "circle.bottomrighthalf.checkered", text: "Noise Reduction", length: 3, frameOffset: 3)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: currentSpacing) {
            ForEach(sections.indices) { index in
                RoundedRectangle(cornerRadius: currentRadius)
                    .fill(.yellow)
                    .frame(width: (currentWidth * sections[index].length) + (frameSpacing * (sections[index].length - 1)) - frameSpacing/2, height: currentTimelineHeight)
                    .overlay(
                        HStack(spacing: 0) {
                            Image(systemName: "chevron.compact.left")
                                .scaleEffect(currentTextSize)

                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: currentRadius - currentTimelineVerticalPadding)
                                    .fill(.black.opacity(0.39))

                                HStack(spacing: 7) {
                                    Image(systemName: sections[index].icon)
                                        .font(.body.weight(.medium))
                                        .symbolRenderingMode(.hierarchical)

                                    Text(sections[index].text)
                                        .font(.subheadline.weight(.medium))
                                }
                                .padding(.horizontal, 10)
                                .scaleEffect(currentTextSize, anchor: .leading)
                            }
                            .padding(.vertical, currentTimelineVerticalPadding)
                            .padding(.horizontal, currentTimelineHorizontalPadding)

                            Image(systemName: "chevron.compact.right")
                                .scaleEffect(currentTextSize)
                        }
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, currentTimelineHorizontalPadding)
                    )
//                    .opacity(selectedSectionIndex == index ? 1.0 : 0.5)
                    .onTapGesture {
                        Haptics.shared.play(.light)
                        selectedSectionIndex = index
                    }
                    .offset(x: (frameSpacing + frameWidth) * sections[index].frameOffset)
            }
        }
        .offset(y: currentOffset)
        .offset(x: -gestureManager.offsetX)
        .animation(.smooth(duration: 0.3), value: ((abs(gestureManager.offsetX)/gestureManager.page) - 9).truncatingRemainder(dividingBy: UIScreen.main.bounds.maxX) == 0)
        .animation(.smooth(duration: 0.3), value: gestureManager.offsetX != 0)

//        .animation(.smooth(duration: 0.3), value: gestureManager.scale != 0.3 || gestureManager.scale != 1)
    }

    func interpolatedValue(for scale: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
        let clampedScale = max(minScale, gestureManager.scale)
        let normalizedScale = (clampedScale - minScale) / (maxScale - minScale)
        let invertedScale = 1 - normalizedScale
        return minVal + normalizedScale * (maxVal - minVal)
    }

    var currentOffset: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 0, maxVal: 80)
    }

    var currentWidth: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: frameWidth * (3/10), maxVal: frameWidth)
    }

    var currentTimelineHeight: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 39, maxVal: 39)
    }

    var currentTimelineHorizontalPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 5, maxVal: 5)
    }

    var currentTimelineVerticalPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 2, maxVal: 2)
    }

    var currentTextSize: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 0.95, maxVal: 0.95)
    }

    var currentRadius: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 7, maxVal: 7)
    }

    var currentSpacing: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 3, maxVal: 3)
    }
}
