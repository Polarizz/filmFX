//
//  FrameRectangle.swift
//  FilmFX
//
//  Created by Paul Wong on 10/12/23.
//

import SwiftUI

struct FrameRectangle: View {

    @ObservedObject var gestureManager: GestureManager

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
                        .animation(.smooth(duration: 0.3), value: gestureManager.scale)
                        .padding(.horizontal, currentLeadingPadding)
                }
            )
            .contentShape(Rectangle())
            .animation(.smooth(duration: 0.3), value: gestureManager.scale)
            .onTapGesture {
                Haptics.shared.play(.light)
                withAnimation(.smooth(duration: 0.3)) { onTap() }
            }
    }

    var rect: some View {
        RoundedRectangle(cornerRadius: currentCornerRadius)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: currentCornerRadius)
                    .strokeBorder(isSelected ? .yellow : .gray.opacity(0.2), lineWidth: isSelected ? currentLineWidth : currentLineWidth/2)
            )
            .frame(width: frameWidth, height: frameWidth * (9/16))
    }

    func interpolatedValue(for scale: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
        let clampedScale = max(minScale, min(gestureManager.scale, maxScale))
        let normalizedScale = (clampedScale - minScale) / (maxScale - minScale)
        let invertedScale = 1 - normalizedScale
        return minVal + invertedScale * (maxVal - minVal)
    }

    var currentCornerRadius: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 0, maxVal: maxCornerRadius)
    }

    var currentLineWidth: CGFloat {
        let m: CGFloat = -2.86
        let b: CGFloat = 3.86
        return m * gestureManager.scale + b
    }

    var currentFontSize: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 16, maxVal: 43)
    }

    var currentSpacing: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 30, maxVal: 70)
    }

    var currentLeadingPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 5, maxVal: 3)
    }
}
