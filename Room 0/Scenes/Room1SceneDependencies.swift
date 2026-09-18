//
//  Room1SceneDependencies.swift
//  Room 0
//

struct Room1SceneDependencies {
    let input: InputBridge
    let presentDialog: (BubbleDialogSequence, (() -> Void)?) -> Void
    let collectItem: (InventoryItem) -> Bool
    let unlockItemUse: () -> Void
    let activeItem: () -> InventoryItem?
    let hasDiscoveredChalkVinegarReaction: () -> Bool
    let presentGuidance: (GuidanceStep, (() -> Void)?) -> Void
}
