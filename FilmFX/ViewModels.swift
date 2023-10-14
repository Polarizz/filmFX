//
//  ViewModels.swift
//  FilmFX
//
//  Created by Paul Wong on 10/13/23.
//

import SwiftUI
import Observation

@Observable
class PageModel: ObservableObject {
    public var currentPage: Int = 0
}

@Observable
class GestureManager: ObservableObject {
    public var scale: CGFloat = 1.0
    public var offsetX: CGFloat = 0
    public var page: CGFloat = 0
}

@Observable
class DragState: ObservableObject {
    public var isDragging: Bool = false
}

@Observable
class TimelineSelectionManager: ObservableObject {
    public var selectedSectionIndex: Int? = nil
}

@Observable
class ScrollManager: ObservableObject {
    public var positionID: Int = 0
}
