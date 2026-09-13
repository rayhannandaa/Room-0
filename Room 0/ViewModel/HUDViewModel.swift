//
//  HUDViewModel.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import Foundation
import Combine

final class HUDViewModel: ObservableObject {
    private let input: InputBridge

    init(input: InputBridge) {
        self.input = input
    }

    func isDirectionalButton(_ buttonName: String) -> Bool {
        direction(for: buttonName) != nil
    }

    func handlePress(for buttonName: String) {
        if let direction = direction(for: buttonName) {
            input.pressedDirection(direction)
        }
    }

    func handleRelease(for buttonName: String) {
        if let direction = direction(for: buttonName) {
            input.releasedDirection(direction)
        }
    }

    func handleTap(for buttonName: String) {
        switch buttonName {
        case "InventoryButton": input.toggleInventory()
        case "ActionButton": input.tappedInteract()
        default: break
        }
    }

    private func direction(for buttonName: String) -> ControlDirection? {
        switch buttonName {
        case "Up": .up
        case "Down": .down
        case "Left": .left
        case "Right": .right
        default: nil
        }
    }
}
