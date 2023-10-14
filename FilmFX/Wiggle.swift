//
//  Wiggle.swift
//  FilmFX
//
//  Created by Paul Wong on 10/14/23.
//

import SwiftUI

extension View {
    func wiggling(_ condition: Bool, amplitude: CGFloat) -> some View {
        self.modifier(WiggleModifier(wiggleCondition: condition, amplitude: amplitude))
    }
}

struct WiggleModifier: ViewModifier {

    @State private var isWiggling = false

    let wiggleCondition: Bool
    let amplitude: CGFloat

    init(wiggleCondition: Bool, amplitude: CGFloat) {
        self.wiggleCondition = wiggleCondition
        self.amplitude = amplitude
    }

    private static func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = abs((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
        return interval + variance * random
    }

    private var rotateAnimation: Animation {
        Animation.easeInOut(duration: WiggleModifier.randomize(interval: 0.11, withVariance: 0.05))
            .repeatForever(autoreverses: true)
    }

    func body(content: Content) -> some View {
        Group {
            if wiggleCondition {
                content
                    .rotationEffect(.degrees(isWiggling ? amplitude : -amplitude), anchor: .center)
                    .onAppear {
                        withAnimation(rotateAnimation) {
                            isWiggling.toggle()
                        }
                    }
            } else {
                content
            }
        }
    }
}
