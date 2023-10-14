//
//  Bar.swift
//  FilmFX
//
//  Created by Paul Wong on 10/13/23.
//

import SwiftUI

struct Bar: View {
    var body: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .frame(height: 1)
    }
}

struct VerticalBar: View {

    private var height: CGFloat

    init(height: CGFloat) {
        self.height = height
    }

    var body: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .frame(width: 1, height: height)
    }
}
