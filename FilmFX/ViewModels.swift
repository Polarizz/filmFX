//
//  ViewModels.swift
//  FilmFX
//
//  Created by Polarizz on 10/13/23.
//

import SwiftUI
import Observation

@Observable
class PageModel: ObservableObject {
    public var currentPage: Int = 0
    public var showTip = true
}

@Observable
class GestureManager: ObservableObject {
    public var scale: CGFloat = 1.0
    public var offsetX: CGFloat = 0
    public var page: CGFloat = 0
}

@Observable
class ControlsManager: ObservableObject {
    public var showEdits = true
    public var showGrid = false
    public var showAudio = false

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
