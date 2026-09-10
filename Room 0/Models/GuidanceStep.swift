//
//  GuidanceStep.swift
//  Room 0
//

import CoreGraphics
import Foundation

enum GuidanceStep: Identifiable {
    case pickupObject
    case inventoryInformation
    case openInventoryForItem
    case prepareSelectedItem
    case applyItem
    case openInventoryForCombination
    case selectFirstCombinationItem(slotIndex: Int)
    case startCombination
    case addCombinationIngredient
    case selectSecondCombinationItem(slotIndex: Int)
    case finishCombination

    var id: String {
        switch self {
        case .pickupObject: return "pickupObject"
        case .inventoryInformation: return "inventoryInformation"
        case .openInventoryForItem: return "openInventoryForItem"
        case .prepareSelectedItem: return "prepareSelectedItem"
        case .applyItem: return "applyItem"
        case .openInventoryForCombination: return "openInventoryForCombination"
        case .selectFirstCombinationItem(let slotIndex):
            return "selectFirstCombinationItem-\(slotIndex)"
        case .startCombination: return "startCombination"
        case .addCombinationIngredient: return "addCombinationIngredient"
        case .selectSecondCombinationItem(let slotIndex):
            return "selectSecondCombinationItem-\(slotIndex)"
        case .finishCombination: return "finishCombination"
        }
    }

    var message: String {
        switch self {
        case .pickupObject:
            return "Tap the action button to pick up nearby objects."
        case .inventoryInformation:
            return "Use the inventory button to check what you've collected."
        case .openInventoryForItem:
            return "Open your inventory to choose an item."
        case .prepareSelectedItem:
            return "Tap Use to prepare the selected item."
        case .applyItem:
            return "Use the action button to apply it to a nearby object."
        case .openInventoryForCombination:
            return "Open your inventory to experiment with the materials."
        case .selectFirstCombinationItem:
            return "Select either the chalk or vinegar."
        case .startCombination:
            return "Tap Combine to place it in the first slot."
        case .addCombinationIngredient:
            return "Tap the + slot to add another ingredient."
        case .selectSecondCombinationItem:
            return "Select the other material from your inventory."
        case .finishCombination:
            return "Tap Combine to test the two materials together."
        }
    }

    var targetButtonCenter: CGPoint {
        switch self {
        case .pickupObject, .applyItem:
            return CGPoint(x: 341, y: 795.05)
        case .inventoryInformation, .openInventoryForItem, .openInventoryForCombination:
            return CGPoint(x: 61, y: 795.05)
        case .prepareSelectedItem:
            return CGPoint(x: 339, y: 550.2)
        case .selectFirstCombinationItem(let slotIndex),
             .selectSecondCombinationItem(let slotIndex):
            guard InventoryLayout.slotRects.indices.contains(slotIndex) else {
                return .zero
            }
            let slotRect = InventoryLayout.slotRects[slotIndex]
            return CGPoint(x: slotRect.midX, y: slotRect.midY)
        case .startCombination:
            return CGPoint(x: 273.5, y: 550.2)
        case .addCombinationIngredient:
            return CGPoint(x: 173.5, y: 504.2)
        case .finishCombination:
            return CGPoint(x: 331.5, y: 550.2)
        }
    }

    var targetButtonSize: CGSize {
        switch self {
        case .prepareSelectedItem:
            return CGSize(width: 50, height: 20)
        case .selectFirstCombinationItem, .addCombinationIngredient,
             .selectSecondCombinationItem:
            return CGSize(width: 45, height: 45)
        case .startCombination, .finishCombination:
            return CGSize(width: 65, height: 20)
        default:
            return CGSize(width: 50, height: 57.5)
        }
    }

    var appearanceDelay: TimeInterval {
        switch self {
        case .pickupObject:
            return 0
        case .inventoryInformation, .openInventoryForItem, .applyItem,
             .openInventoryForCombination:
            return 0.25
        case .prepareSelectedItem, .selectFirstCombinationItem,
             .startCombination, .addCombinationIngredient,
             .selectSecondCombinationItem, .finishCombination:
            return 0.3
        }
    }
}
