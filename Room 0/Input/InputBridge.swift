//
//  InputBridge.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import Foundation
import Combine

enum ControlDirection {
    case up, down, left, right
}

final class InputBridge: ObservableObject {
    @Published var pendingDirection: ControlDirection? = nil
    @Published var isInventoryOpen: Bool = false
    @Published var interactTrigger: Int = 0
    @Published var controlsEnabled: Bool = false
    @Published private(set) var isOpeningSequencePending: Bool = true

    func beginOpeningSequence() {
        isOpeningSequencePending = false
    }

    func tappedDirection(_ direction: ControlDirection) {
        guard controlsEnabled, !isInventoryOpen else { return }
        pendingDirection = direction
    }

    func tappedInteract() {
        guard controlsEnabled, !isInventoryOpen else { return }
        interactTrigger += 1
    }

    func toggleInventory() {
        guard controlsEnabled else { return }
        isInventoryOpen.toggle()
    }
}
