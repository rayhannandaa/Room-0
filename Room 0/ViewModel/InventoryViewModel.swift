//
//  InventoryViewModel.swift
//  Room 0
//
//  Created by Rayhan Nanda on 08/09/26.
//

import Foundation
import Combine

final class InventoryViewModel: ObservableObject {
    private let input: InputBridge
    private var cancellable: AnyCancellable?
    private let combinationRecipes = InventoryCombinationRecipe.roomOneRecipes
    private let combinationCompletedHandler: (InventoryCombinationRecipe) -> Void
    private var completedCombinationIngredients: Set<Set<String>> = []
    
    @Published private(set) var slots: [InventoryItem?]
    @Published private(set) var isVisible: Bool = false
    @Published private(set) var selectedIndex: Int? = nil
    @Published private(set) var activeItemID: String? = nil
    @Published private(set) var isUseAvailable: Bool = false
    @Published private(set) var isCombineAvailable: Bool = false
    @Published private(set) var combinationFirstIndex: Int? = nil
    @Published private(set) var combinationSecondIndex: Int? = nil
    @Published private(set) var isChoosingSecondIngredient = false
    
    private let slotCount = InventoryLayout.columns * InventoryLayout.rows
    
    var selectedItem: InventoryItem? {
        guard let index = selectedIndex, slots.indices.contains(index) else { return nil }
        return slots[index]
    }
    
    var isSelectedItemActive: Bool {
        guard let selected = selectedItem else { return false }
        return selected.id == activeItemID
    }

    var activeItem: InventoryItem? {
        guard let activeItemID else { return nil }
        return slots.compactMap { $0 }.first(where: { $0.id == activeItemID })
    }

    var isCombining: Bool {
        combinationFirstIndex != nil
    }

    var combinationFirstItem: InventoryItem? {
        item(at: combinationFirstIndex)
    }

    var combinationSecondItem: InventoryItem? {
        item(at: combinationSecondIndex)
    }

    var canSelectedItemCombine: Bool {
        guard isCombineAvailable, let selectedItem else { return false }
        return combinationRecipes.contains { recipe in
            recipe.ingredientNames.contains(selectedItem.name)
        }
    }

    var matchingCombinationRecipe: InventoryCombinationRecipe? {
        guard let firstItem = combinationFirstItem,
              let secondItem = combinationSecondItem
        else {
            return nil
        }

        return combinationRecipes.first { recipe in
            recipe.matches(firstItem, secondItem)
        }
    }

    var combinationInstruction: String {
        if isChoosingSecondIngredient {
            return "Select another inventory item."
        }
        if combinationSecondItem == nil {
            return "Tap the empty slot to add an item."
        }
        if matchingCombinationRecipe != nil {
            return "Ready to combine."
        }
        return "These items cannot be combined."
    }

    var hasDiscoveredChalkVinegarReaction: Bool {
        completedCombinationIngredients.contains(["Chalk", "Vinegar"])
    }
    
    init(
        input: InputBridge,
        combinationCompletedHandler: @escaping (InventoryCombinationRecipe) -> Void = { _ in }
    ) {
        self.input = input
        self.combinationCompletedHandler = combinationCompletedHandler
        self.slots = Array(repeating: nil, count: slotCount)
        
        cancellable = input.$isInventoryOpen
            .receive(on: DispatchQueue.main)
            .sink { [weak self] open in
                self?.isVisible = open
                if !open {
                    self?.selectedIndex = nil
                    self?.cancelCombination()
                }
            }
    }
    
    func dismiss() {
        input.isInventoryOpen = false
    }
    
    func selectSlot(at index: Int) {
        guard slots.indices.contains(index), slots[index] != nil else { return }

        if isCombining {
            guard isChoosingSecondIngredient,
                  index != combinationFirstIndex
            else {
                return
            }

            combinationSecondIndex = index
            isChoosingSecondIngredient = false
            return
        }

        selectedIndex = (selectedIndex == index) ? nil : index
    }

    func startCombination() {
        guard canSelectedItemCombine, let selectedIndex else { return }
        combinationFirstIndex = selectedIndex
        combinationSecondIndex = nil
        isChoosingSecondIngredient = false
    }

    func beginChoosingSecondIngredient() {
        guard isCombining else { return }
        combinationSecondIndex = nil
        isChoosingSecondIngredient = true
    }

    func cancelCombination() {
        combinationFirstIndex = nil
        combinationSecondIndex = nil
        isChoosingSecondIngredient = false
    }

    func completeCombination() {
        guard let recipe = matchingCombinationRecipe else { return }

        completedCombinationIngredients.insert(recipe.ingredientNames)
        cancelCombination()
        input.isInventoryOpen = false
        combinationCompletedHandler(recipe)
    }
    
    @discardableResult
    func useSelectedItem() -> Bool {
        guard let item = selectedItem else { return false }
        activeItemID = item.id
        input.isInventoryOpen = false
        return true
    }

    func unlockItemUse() {
        isUseAvailable = true
    }

    func unlockItemCombination() {
        isCombineAvailable = true
    }

    func firstCombinationTutorialItemIndex() -> Int? {
        slots.firstIndex { item in
            guard let item else { return false }
            return item.name == "Chalk" || item.name == "Vinegar"
        }
    }

    func remainingCombinationTutorialItemIndex() -> Int? {
        guard let firstItem = combinationFirstItem else { return nil }
        let remainingItemName = firstItem.name == "Chalk" ? "Vinegar" : "Chalk"
        return slots.firstIndex { $0?.name == remainingItemName }
    }

    @discardableResult
    func openForItemUseGuidance(itemNamed itemName: String) -> Bool {
        guard let itemIndex = slots.firstIndex(where: { $0?.name == itemName }) else {
            return false
        }

        selectedIndex = itemIndex
        input.isInventoryOpen = true
        return true
    }
    
    @discardableResult
    func addItem(_ item: InventoryItem) -> Bool {
        guard let emptyIndex = slots.firstIndex(where: { $0 == nil }) else {
            return false
        }
        slots[emptyIndex] = item
        return true
    }

    @discardableResult
    func collectAndPresent(_ item: InventoryItem) -> Bool {
        guard let emptyIndex = slots.firstIndex(where: { $0 == nil }) else {
            return false
        }

        slots[emptyIndex] = item
        selectedIndex = emptyIndex
        activeItemID = nil
        input.isInventoryOpen = true
        return true
    }
    
    func removeItem(at index: Int) {
        guard slots.indices.contains(index) else { return }
        if let removedID = slots[index]?.id, removedID == activeItemID {
            activeItemID = nil
        }
        slots[index] = nil
        if selectedIndex == index {
            selectedIndex = nil
        }
    }

    private func item(at index: Int?) -> InventoryItem? {
        guard let index, slots.indices.contains(index) else { return nil }
        return slots[index]
    }
}
