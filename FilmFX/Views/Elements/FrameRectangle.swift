//
//  FrameRectangle.swift
//  FilmFX
//
//  Created by Paul Wong on 10/12/23.
//

import SwiftUI

struct FrameRectangle: View {

    @ObservedObject var zoomScale: ZoomScale

    let maxCornerRadius: CGFloat = 19
    let maxLineWidth: CGFloat = 3
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 1.0

    var number: Int
    var frameWidth: CGFloat
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        rect
            .overlay(
                VStack(alignment: .leading, spacing: currentSpacing) {
                    rect.opacity(0)

                    Text(String(number))
                        .font(.system(size: currentFontSize))
                        .foregroundColor(isSelected ? .yellow : .gray.opacity(0.5))
                        .animation(.smooth(duration: 0.3), value: zoomScale.scale)
                        .padding(.horizontal, currentLeadingPadding)
                }
            )
    }

    var rect: some View {
        RoundedRectangle(cornerRadius: currentCornerRadius)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: currentCornerRadius)
                    .strokeBorder(isSelected ? .yellow : .secondary, lineWidth: isSelected ? currentLineWidth : 1)
            )
            .frame(width: frameWidth, height: frameWidth * (9/16))
            .animation(.smooth(duration: 0.3), value: zoomScale.scale)
            .onTapGesture {
                withAnimation(.smooth(duration: 0.3)) { onTap() }
            }
    }

    func interpolatedValue(for scale: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
        let clampedScale = max(minScale, min(zoomScale.scale, maxScale))
        let normalizedScale = (clampedScale - minScale) / (maxScale - minScale)
        let invertedScale = 1 - normalizedScale
        return minVal + invertedScale * (maxVal - minVal)
    }

    var currentCornerRadius: CGFloat {
        interpolatedValue(for: zoomScale.scale, minVal: 0, maxVal: maxCornerRadius)
    }

    var currentLineWidth: CGFloat {
        let m: CGFloat = -2.86
        let b: CGFloat = 3.86
        return m * zoomScale.scale + b
    }

    var currentFontSize: CGFloat {
        interpolatedValue(for: zoomScale.scale, minVal: 16, maxVal: 43)
    }

    var currentSpacing: CGFloat {
        interpolatedValue(for: zoomScale.scale, minVal: 30, maxVal: 70)
    }

    var currentLeadingPadding: CGFloat {
        interpolatedValue(for: zoomScale.scale, minVal: 5, maxVal: 3)
    }
}
