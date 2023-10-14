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
                        .font(.custom("SFCamera", size: currentFontSize))
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
            .wiggling(isSelected, amplitude: wiggleAmplitude)
    }

    var rect: some View {
        Image("poppy")
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: frameWidth, height: frameWidth * (9/16))
            .brightness(isSelected ? -0.1 : 0)
            .clipShape(RoundedRectangle(cornerRadius: currentCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: currentCornerRadius)
                    .strokeBorder(isSelected ? .yellow : .gray.opacity(0.2), lineWidth: isSelected ? currentLineWidth : currentLineWidth/2)
            )
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
        interpolatedValue(for: gestureManager.scale, minVal: 3, maxVal: 9)
    }

    var currentFontSize: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 17, maxVal: 52)
    }

    var currentSpacing: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 30, maxVal: 70)
    }

    var currentLeadingPadding: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 7, maxVal: 3)
    }

    var currentCircleSize: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 5, maxVal: 15)
    }

    var currentCircleOffset: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 18, maxVal: 45)
    }

    var wiggleAmplitude: CGFloat {
        interpolatedValue(for: gestureManager.scale, minVal: 1, maxVal: 2)
    }
}
