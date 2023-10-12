//
//  Timeline.swift
//  FilmFX
//
//  Created by Paul Wong on 10/12/23.
//

import SwiftUI

struct Timeline: View {

    @ObservedObject var gestureManager: GestureManager

    var frameSpacing: CGFloat

    let frameWidth: CGFloat = UIScreen.main.bounds.maxX
    let totalFrames: Int = 30
    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: currentRadius)
                .fill(.yellow)
                .frame(width: (frameWidth * 3) + (frameSpacing * 2), height: currentTimelineHeight)
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
                                Image(systemName: "circle.rectangle.filled.pattern.diagonalline")
                                    .font(.body.weight(.medium))
                                    .symbolRenderingMode(.hierarchical)

                                Text("Vignette")
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

            RoundedRectangle(cornerRadius: currentRadius)
                .fill(.yellow)
                .frame(width: (frameWidth * 3) + (frameSpacing * 2), height: currentTimelineHeight)
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
                                Image(systemName: "circle.rectangle.filled.pattern.diagonalline")
                                    .font(.body.weight(.medium))
                                    .symbolRenderingMode(.hierarchical)

                                Text("Vignette")
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
                .offset(x: frameSpacing + frameWidth)
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
        interpolatedValue(for: gestureManager.scale, minVal: 40, maxVal: 130)
    }

    var currentTimelineHorizontalPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 5, maxVal: 24)
    }

    var currentTimelineVerticalPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 2, maxVal: 6)
    }

    var currentTextSize: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 1, maxVal: 3)
    }

    var currentRadius: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 7, maxVal: 21)
    }
}
