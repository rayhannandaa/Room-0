//
//  GuidanceViewModel.swift
//  Room 0
//

import Foundation
import Combine

@MainActor
final class GuidanceViewModel: ObservableObject {
    @Published private(set) var currentStep: GuidanceStep?

    private let input: InputBridge
    private let inventoryViewModel: InventoryViewModel
    private var completion: (() -> Void)?

    init(input: InputBridge, inventoryViewModel: InventoryViewModel) {
        self.input = input
        self.inventoryViewModel = inventoryViewModel
    }

    func present(_ step: GuidanceStep, completion: (() -> Void)? = nil) {
        self.completion = completion
        currentStep = step
    }

    func handleHighlightedButtonTap() {
        guard let step = currentStep else { return }

        let completion = completion
        self.completion = nil
        currentStep = nil

        switch step {
        case .pickupObject:
            input.tappedInteract()
            completion?()

        case .inventoryInformation:
            completion?()

        case .openInventoryForItem:
            if inventoryViewModel.openForItemUseGuidance(itemNamed: "Matchbox") {
                present(.prepareSelectedItem)
            } else {
                completion?()
            }

        case .prepareSelectedItem:
            if inventoryViewModel.useSelectedItem() {
                present(.applyItem)
            } else {
                completion?()
            }

        case .applyItem:
            input.tappedInteract()
            completion?()

        case .openInventoryForCombination:
            inventoryViewModel.unlockItemCombination()
            input.isInventoryOpen = true

            if let slotIndex = inventoryViewModel.firstCombinationTutorialItemIndex() {
                present(.selectFirstCombinationItem(slotIndex: slotIndex), completion: completion)
            } else {
                completion?()
            }

        case .selectFirstCombinationItem(let slotIndex):
            inventoryViewModel.selectSlot(at: slotIndex)
            present(.startCombination, completion: completion)

        case .startCombination:
            inventoryViewModel.startCombination()
            present(.addCombinationIngredient, completion: completion)

        case .addCombinationIngredient:
            inventoryViewModel.beginChoosingSecondIngredient()

            if let slotIndex = inventoryViewModel.remainingCombinationTutorialItemIndex() {
                present(.selectSecondCombinationItem(slotIndex: slotIndex), completion: completion)
            } else {
                completion?()
            }

        case .selectSecondCombinationItem(let slotIndex):
            inventoryViewModel.selectSlot(at: slotIndex)
            present(.finishCombination, completion: completion)

        case .finishCombination:
            inventoryViewModel.completeCombination()
            completion?()
        }
    }
}
