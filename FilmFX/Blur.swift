//
//  Blur.swift
//  FilmFX
//
//  Created by Paul Wong on 10/13/23.
//

import SwiftUI
import UIKit

/// Blured Background
struct Blur: UIViewRepresentable {

    var style: UIBlurEffect.Style = .systemMaterial

    init(_ style: UIBlurEffect.Style) {
        self.style = style
    }

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
