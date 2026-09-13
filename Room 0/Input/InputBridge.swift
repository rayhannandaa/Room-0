//
//  InputBridge.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import Foundation
import Combine

enum ControlDirection: Equatable {
    case up, down, left, right
}

final class InputBridge: ObservableObject {
    @Published var pendingDirection: ControlDirection? = nil
    @Published private(set) var heldDirection: ControlDirection? = nil
    @Published var isInventoryOpen: Bool = false
    @Published var interactTrigger: Int = 0
    @Published var controlsEnabled: Bool = false {
        didSet {
            if !controlsEnabled {
                cancelMovement()
            }
        }
    }
    @Published private(set) var isOpeningSequencePending: Bool = true

    func beginOpeningSequence() {
        isOpeningSequencePending = false
    }

    func pressedDirection(_ direction: ControlDirection) {
        guard controlsEnabled, !isInventoryOpen else { return }
        heldDirection = direction
        pendingDirection = direction
    }

    func releasedDirection(_ direction: ControlDirection) {
        guard heldDirection == direction else { return }
        heldDirection = nil
    }

    func cancelMovement() {
        heldDirection = nil
        pendingDirection = nil
    }

    func tappedInteract() {
        guard controlsEnabled, !isInventoryOpen else { return }
        interactTrigger += 1
    }

    func toggleInventory() {
        guard controlsEnabled else { return }
        if !isInventoryOpen {
            cancelMovement()
        }
        isInventoryOpen.toggle()
    }
}
