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

    func handleTap(for buttonName: String) {
        switch buttonName {
        case "Up": input.tappedDirection(.up)
        case "Down": input.tappedDirection(.down)
        case "Left": input.tappedDirection(.left)
        case "Right": input.tappedDirection(.right)
        case "InventoryButton": input.toggleInventory()
        case "ActionButton": input.tappedInteract()
        default: break
        }
    }
}
