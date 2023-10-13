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

    var frameSpacing: CGFloat

    let frameWidth: CGFloat = UIScreen.main.bounds.maxX
    let totalFrames: Int = 30
    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 1.0

    let sections: [TimelineSection] = [
        TimelineSection(icon: "circle.dotted.circle", text: "Vignette", length: 3, frameOffset: 0),
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
                     .frame(width: (frameWidth * sections[index].length) + (frameSpacing * (sections[index].length - 1)), height: currentTimelineHeight)
                     .animation(.smooth(duration: 0.3), value: gestureManager.offsetX != 0)
                     .animation(.smooth(duration: 0.3), value: gestureManager.scale != 0.3 || gestureManager.scale != 1)
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
                     .offset(x: (frameSpacing + frameWidth) * sections[index].frameOffset)
             }
         }
         .offset(y: currentOffset)
     }

    func interpolatedValue(for scale: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
        let clampedScale = max(minScale, min(gestureManager.scale, maxScale))
        let normalizedScale = (clampedScale - minScale) / (maxScale - minScale)
        let invertedScale = 1 - normalizedScale
        return minVal + invertedScale * (maxVal - minVal)
    }

    var currentOffset: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 230, maxVal: 300)
    }

    var currentTimelineHeight: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 35, maxVal: 135)
    }

    var currentTimelineHorizontalPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 5, maxVal: 24)
    }

    var currentTimelineVerticalPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 2, maxVal: 6.5)
    }

    var currentTextSize: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 0.95, maxVal: 3)
    }

    var currentRadius: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 7, maxVal: 22)
    }

    var currentSpacing: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 3, maxVal: 10)
    }
}
