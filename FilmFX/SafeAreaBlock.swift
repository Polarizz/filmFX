//
//  SafeAreaBlock.swift
//  FilmFX
//
//  Created by Paul Wong on 10/14/23.
//

import SwiftUI

struct SafeAreaBlockTop: View {

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) private var colorScheme

    @State var height: CGFloat = 100

    var minimized: Bool = false

    var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
//        Color.red
            .frame(
                width: 9999,
                height: height*2
            )
            .padding(.horizontal, -200)
            .blur(radius: 20)
            .contrast(1.5)
            .saturation(1.3)
            .brightness(-0.3)
            .offset(
                y:
                    -height/(minimized ? 0.7 : 1)
            )
            .ignoresSafeArea(.container)
            .allowsHitTesting(false)
    }
}

struct SafeAreaBlockBottom: View {

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) private var colorScheme

    @State var height: CGFloat = 100

    var minimized: Bool = false

    var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
//        Color.red
            .frame(
                width: 9999,
                height: height*2.2
            )
            .padding(.horizontal, -200)
            .blur(radius: 20)
            .contrast(1.5)
            .saturation(1.3)
            .brightness(-0.3)
            .offset(
                y:
                    height
            )
            .ignoresSafeArea(.container)
            .allowsHitTesting(false)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
